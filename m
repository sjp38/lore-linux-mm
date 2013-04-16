Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 74D446B0006
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 14:47:51 -0400 (EDT)
Message-ID: <516D9CD5.6000807@linux.intel.com>
Date: Tue, 16 Apr 2013 11:47:49 -0700
From: Darren Hart <dvhart@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] futex: bugfix for futex-key conflict when futex use hugepage
References: <OF000BBE68.EBB4E92E-ON48257B4F.0010C2E7-48257B4F.0013FB89@zte.com.cn> <516D9A74.8030109@linux.intel.com>
In-Reply-To: <516D9A74.8030109@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: zhang.yi20@zte.com.cn, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>



On 04/16/2013 11:37 AM, Dave Hansen wrote:
> Instead of bothering to store the index, why not just calculate it, like:
> 
> On 04/15/2013 08:37 PM, zhang.yi20@zte.com.cn wrote:
>> +static inline int get_page_compound_index(struct page *page)
>> +{
>> +       if (PageHead(page))
>> +               return 0;
>> +       return compound_head(page) - page;
>> +}
> 
> BTW, you've really got to get your mail client fixed.  Your patch is
> still line-wrapped.

And with this it would no longer be necessary to store this index at
all, eliminating all changes to the MM other than this accessor function
- which if not needed there could be added to futex.c, or even replaced with
"page_head - page" in get_futex_key() right?

-- 
Darren Hart
Intel Open Source Technology Center
Yocto Project - Technical Lead - Linux Kernel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
