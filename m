Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id 88FC86B0031
	for <linux-mm@kvack.org>; Sat, 14 Dec 2013 14:48:31 -0500 (EST)
Received: by mail-qc0-f177.google.com with SMTP id m20so2550751qcx.8
        for <linux-mm@kvack.org>; Sat, 14 Dec 2013 11:48:31 -0800 (PST)
Received: from comal.ext.ti.com (comal.ext.ti.com. [198.47.26.152])
        by mx.google.com with ESMTPS id v3si6757379qat.53.2013.12.14.11.48.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 14 Dec 2013 11:48:29 -0800 (PST)
Message-ID: <52ACB608.3050802@ti.com>
Date: Sat, 14 Dec 2013 14:48:24 -0500
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 08/23] mm/memblock: Add memblock memory allocation
 apis
References: <1386625856-12942-1-git-send-email-santosh.shilimkar@ti.com> <1386625856-12942-9-git-send-email-santosh.shilimkar@ti.com> <20131213213735.GM27070@htj.dyndns.org> <52ABABDA.4020808@ti.com> <20131214110844.GB17954@htj.dyndns.org>
In-Reply-To: <20131214110844.GB17954@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Strashko, Grygorii" <grygorii.strashko@ti.com>

On Saturday 14 December 2013 06:08 AM, Tejun Heo wrote:
> Hello, Santosh.
> 
> On Fri, Dec 13, 2013 at 07:52:42PM -0500, Santosh Shilimkar wrote:
>>>> +static void * __init memblock_virt_alloc_internal(
>>>> +				phys_addr_t size, phys_addr_t align,
>>>> +				phys_addr_t min_addr, phys_addr_t max_addr,
>>>> +				int nid)
>>>> +{
>>>> +	phys_addr_t alloc;
>>>> +	void *ptr;
>>>> +
>>>> +	if (nid == MAX_NUMNODES)
>>>> +		pr_warn("%s: usage of MAX_NUMNODES is depricated. Use NUMA_NO_NODE\n",
>>>> +			__func__);
>>>
>>> Why not use WARN_ONCE()?  Also, shouldn't nid be set to NUMA_NO_NODE
>>> here?
>>>
>> You want all the users using MAX_NUMNODES to know about it so that
>> the wrong usage can be fixed. WARN_ONCE will hide that.
> 
> Well, it doesn't really help anyone to be printing multiple messages
> without any info on who was the caller and if this thing is gonna be
> in mainline triggering of the warning should be rare anyway.  It's
> more of a tool to gather one-off cases in the wild.  WARN_ONCE()
> usually is the better choice as otherwise the warnings can swamp the
> machine and console output in certain cases.
>
Fair enough.
 
>>> ...
>>>> +	if (nid != NUMA_NO_NODE) {
>>>
>>> Otherwise, the above test is broken.
>>>
>> So the idea was just to warn the users and allow them to fix
>> the code. Well we are just allowing the existing users of using
>> either MAX_NUMNODES or NUMA_NO_NODE continue to work. Thats what
>> we discussed, right ?
> 
> Huh?  Yeah, sure.  You're testing @nid against MAX_NUMNODES at the
> beginning of the function.  If it's MAX_NUMNODES, you print a warning
> but nothing else, so the if() conditional above, which should succeed,
> would fail.  Am I missing sth here?
> 
I get it now. Sorry I missed your point in first part. We will fix this.

Regards,
Santosh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
