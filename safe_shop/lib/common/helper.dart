bool isNullEmptyOrFalse(Object o) => o == null || false == o || "" == o;
bool isNullOrEmpty(Object o) => o == null || "" == o || "null" == o;
bool isNullEmptyFalseOrZero(Object o) =>
    o == null || false == o || 0 == o || "" == o;
