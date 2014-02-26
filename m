Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id AC88B6B00A5
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 11:17:23 -0500 (EST)
Received: by mail-we0-f169.google.com with SMTP id t61so1858644wes.28
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 08:17:23 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id md3si10707077wic.60.2014.02.26.08.17.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 26 Feb 2014 08:17:22 -0800 (PST)
Message-ID: <530E2518.5090102@suse.de>
Date: Wed, 26 Feb 2014 18:32:08 +0100
From: Alexander Graf <agraf@suse.de>
MIME-Version: 1.0
Subject: Re: [PATCH] ksm: Expose configuration via sysctl
References: <1393284484-27637-1-git-send-email-agraf@suse.de> <530CD443.7010400@intel.com> <4B3C0B08-45E1-48EF-8030-A3365F0E7CF6@suse.de> <530D3102.60504@intel.com> <alpine.DEB.2.10.1402261634010.31425@aurora64.sdinet.de>
In-Reply-To: <alpine.DEB.2.10.1402261634010.31425@aurora64.sdinet.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sven-Haegar Koch <haegar@sdinet.de>
Cc: Dave Hansen <dave.hansen@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>

Sven-Haegar Koch wrote:
> On Tue, 25 Feb 2014, Dave Hansen wrote:
>
>   
>> On 02/25/2014 03:09 PM, Alexander Graf wrote:
>>     
>>>> Couldn't we also (maybe in parallel) just teach the sysctl userspace
>>>> about sysfs?  This way we don't have to do parallel sysctls and sysfs
>>>> for *EVERYTHING* in the kernel:
>>>>
>>>>    sysfs.kernel.mm.transparent_hugepage.enabled=enabled
>>>>         
>>> It's pretty hard to filter this. We definitely do not want to expose all of sysfs through /proc/sys. But how do we know which files are actual configuration and which ones are dynamic system introspection data?
>>>
>>> We could add a filter, but then we can just as well stick with the manual approach I followed here :).
>>>       
>> Maybe not stick it under /proc/sys, but teach sysctl(8) about them.  I
>> guess at the moment, sysctl says that it's tied to /proc/sys:
>>
>>     
>>> DESCRIPTION
>>>        sysctl  is  used to modify kernel parameters at runtime.  The parameters available are those listed under /proc/sys/.  Procfs is required
>>>        for sysctl support in Linux.  You can use sysctl to both read and write sysctl data.
>>>       
>> But surely that's not set in stone just because the manpage says so. :)
>>     
>
> What I still don't get is why you need this?
>
> My distribution (Debian) has a sysfsutils package which provides a 
> /etc/sysfs.conf / /etc/sysfs.d/foo exactly like /etc/sysctl.conf.
>
> Don't other distributions have something like this?
>   

Maybe that's the right answer to the problem, but I still don't
understand why these properties were put into sysfs in the first place.
We're not configuring a dynamic device here, are we?

Also if we do want something like a sysfs.conf and sysfs.d, that should
probably be something that gets properly coordinated between
distributions so that users don't get completely confused. Today
openSUSE does not have a sysfs.conf/.d provided by the sysfsutils
package. Maybe it's something homegrown?


Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
