Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 120C26B0062
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 05:10:20 -0400 (EDT)
Date: 31 Oct 2012 05:10:18 -0400
Message-ID: <20121031091018.24875.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
Subject: Re: [dm-devel] [PATCH v8 01/16] hashtable: introduce a small and naive hashtable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org
Cc: dm-devel@redhat.com, levinsasha928@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, netdev@vger.kernel.org

Tejun Heo wrote:
>> +#define hash_min(val, bits)						\
>> +({									\
>> +	sizeof(val) <= 4 ?						\
>> +	hash_32(val, bits) :						\
>> +	hash_long(val, bits);						\
>> +})

> Also, you probably want () around at least @val.  In general,
> it's a good idea to add () around any macro argument to avoid nasty
> surprises.

Er... not in this case, you don't.  If a macro argument is passed verbatim
as an argument to a function, it doesn't need additional parens.

That's because the one guarantee you have about a macro argument is
that it can't contain any (unquoted) commas, and there's nothing lower
precedence than the comma.  So it's safe to delimit a macro argument
with *either* parens *or* a comma.

So you can go ahead and write:

#define hash_min(val, bits) \
	(sizeof(val) <= 4 ? hash_32(val, bits) : hash_long(val, bits))

... which is easier to read, anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
