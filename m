Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 80C8A6B0098
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 19:10:44 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so151344pde.41
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 16:10:44 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id on3si5192892pbb.185.2014.02.25.16.10.43
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 16:10:43 -0800 (PST)
Message-ID: <530D3102.60504@intel.com>
Date: Tue, 25 Feb 2014 16:10:42 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] ksm: Expose configuration via sysctl
References: <1393284484-27637-1-git-send-email-agraf@suse.de> <530CD443.7010400@intel.com> <4B3C0B08-45E1-48EF-8030-A3365F0E7CF6@suse.de>
In-Reply-To: <4B3C0B08-45E1-48EF-8030-A3365F0E7CF6@suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Graf <agraf@suse.de>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>

On 02/25/2014 03:09 PM, Alexander Graf wrote:
>> Couldn't we also (maybe in parallel) just teach the sysctl userspace
>> about sysfs?  This way we don't have to do parallel sysctls and sysfs
>> for *EVERYTHING* in the kernel:
>>
>>    sysfs.kernel.mm.transparent_hugepage.enabled=enabled
> 
> It's pretty hard to filter this. We definitely do not want to expose all of sysfs through /proc/sys. But how do we know which files are actual configuration and which ones are dynamic system introspection data?
> 
> We could add a filter, but then we can just as well stick with the manual approach I followed here :).

Maybe not stick it under /proc/sys, but teach sysctl(8) about them.  I
guess at the moment, sysctl says that it's tied to /proc/sys:

> DESCRIPTION
>        sysctl  is  used to modify kernel parameters at runtime.  The parameters available are those listed under /proc/sys/.  Procfs is required
>        for sysctl support in Linux.  You can use sysctl to both read and write sysctl data.

But surely that's not set in stone just because the manpage says so. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
