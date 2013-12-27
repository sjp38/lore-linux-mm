Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f49.google.com (mail-yh0-f49.google.com [209.85.213.49])
	by kanga.kvack.org (Postfix) with ESMTP id AB57C6B0031
	for <linux-mm@kvack.org>; Fri, 27 Dec 2013 17:19:51 -0500 (EST)
Received: by mail-yh0-f49.google.com with SMTP id z20so2027286yhz.22
        for <linux-mm@kvack.org>; Fri, 27 Dec 2013 14:19:51 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id r49si35169000yho.67.2013.12.27.14.19.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 27 Dec 2013 14:19:50 -0800 (PST)
Message-ID: <52BDFD00.7020909@oracle.com>
Date: Fri, 27 Dec 2013 17:19:44 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: dump page when hitting a VM_BUG_ON using VM_BUG_ON_PAGE
References: <1388114452-30769-1-git-send-email-sasha.levin@oracle.com> <20131227103847.GA19453@node.dhcp.inet.fi>
In-Reply-To: <20131227103847.GA19453@node.dhcp.inet.fi>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/27/2013 05:38 AM, Kirill A. Shutemov wrote:
> On Thu, Dec 26, 2013 at 10:20:52PM -0500, Sasha Levin wrote:
>> Most of the VM_BUG_ON assertions are performed on a page. Usually, when
>> one of these assertions fails we'll get a BUG_ON with a call stack and
>> the registers.
>>
>> I've recently noticed based on the requests to add a small piece of code
>> that dumps the page to various VM_BUG_ON sites that the page dump is quite
>> useful to people debugging issues in mm.
>>
>> This patch adds a VM_BUG_ON_PAGE(cond, page) which beyond doing what
>> VM_BUG_ON() does, also dumps the page before executing the actual BUG_ON.
>>
>> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
>
> I like the idea. One thing I've noticed you have a lot of page flag based
> asserts, like:
>
> 	VM_BUG_ON_PAGE(PageLRU(page), page);
> 	VM_BUG_ON_PAGE(!PageLocked(page), page);
>
> What about adding per-page-flag assert macros, like:
>
> 	PageNotLRU_assert(page);
> 	PageLocked_assert(page);
>
> ? This way we will always dump right page on bug.
>

Sure, sounds good.

I'll send another patch on top of this one.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
