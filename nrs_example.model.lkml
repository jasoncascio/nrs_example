connection: "jc-looker"

include: "*.view.lkml"                # include all views in the views/ folder in this project

#### Expecting this doesn't fit your scenario 100%, but maybe there's something here that's useful.
###
### Example query: https://looker.da-ce.xyz/explore/nrs_example/sales?fields=calendar.purchase_date,sales.sales,calendar.comp_period&f[calendar.timeframe_selector]=2024%2F08%2F15+to+2024%2F08%2F20&sorts=calendar.purchase_date+desc&limit=500&column_limit=50&vis=%7B%7D&filter_config=%7B%22calendar.timeframe_selector%22%3A%5B%7B%22type%22%3A%22between%22%2C%22values%22%3A%5B%7B%22date%22%3A%222024-08-15T00%3A00%3A00.000Z%22%2C%22tz%22%3Atrue%7D%2C%7B%22date%22%3A%222024-08-20T00%3A00%3A00.000Z%22%2C%22tz%22%3Atrue%7D%5D%2C%22id%22%3A3%2C%22error%22%3Afalse%7D%5D%7D&dynamic_fields=%5B%5D&origin=share-expanded

explore: sales {

  join: calendar {
    type: left_outer
    relationship: many_to_one
    sql_on: ${sales.purchase_date} = ${calendar.purchase_date};;
  }

  sql_always_where: 1=1
    {% if calendar.timeframe_selector._in_query %} AND
      ${sales.purchase_date} IN (
          SELECT ty_date FROM ${calendar_lookup.SQL_TABLE_NAME}
          WHERE ty_date >= DATE({% date_start  calendar.timeframe_selector %})
          AND ty_date <= DATE({% date_end  calendar.timeframe_selector %})

          UNION ALL

          SELECT ly_date FROM ${calendar_lookup.SQL_TABLE_NAME}
          WHERE ty_date >= DATE({% date_start  calendar.timeframe_selector %})
          AND ty_date <= DATE({% date_end  calendar.timeframe_selector %})
      )
    {% endif %}
  ;;
}
