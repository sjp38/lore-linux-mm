Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id E38106B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 13:37:00 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id b20so803503yha.12
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 10:37:00 -0800 (PST)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id v21si5361559yhm.298.2014.01.16.10.36.53
        for <linux-mm@kvack.org>;
        Thu, 16 Jan 2014 10:36:53 -0800 (PST)
Message-ID: <52D82668.1060400@sr71.net>
Date: Thu, 16 Jan 2014 10:35:20 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 4/9] mm: slabs: reset page at free
References: <20140114180042.C1C33F78@viggo.jf.intel.com> <20140114180054.20A1B660@viggo.jf.intel.com> <alpine.DEB.2.02.1401141847230.32645@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1401141847230.32645@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org, cl@linux-foundation.org

On 01/14/2014 06:48 PM, David Rientjes wrote:
>> > +/*
>> > + * Custom allocators (like the slabs) use 'struct page' fields
>> > + * for all kinds of things.  This resets the page's state so that
>> > + * the buddy allocator will be happy with it.
>> > + */
>> > +static inline void allocator_reset_page(struct page *page)
> This is ambiguous as to what "allocator" you're referring to unless we 
> look at the comment.  I think it would be better to name it 
> slab_reset_page() or something similar.

I stuck it in mm.h and deliberately didn't call it 'slab_something' so
that zsmalloc (in staging) could use this as well.  The "allocator" part
of the name was to indicate that any allocator could use it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
