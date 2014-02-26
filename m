Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 6AD086B0036
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 10:35:52 -0500 (EST)
Received: by mail-ee0-f43.google.com with SMTP id e53so462852eek.30
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 07:35:51 -0800 (PST)
Received: from mail.sdinet.de (mail.sdinet.de. [2001:6f8:94b::74])
        by mx.google.com with ESMTPS id p44si2854428eeu.26.2014.02.26.07.35.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Feb 2014 07:35:51 -0800 (PST)
Date: Wed, 26 Feb 2014 16:36:33 +0100 (CET)
From: Sven-Haegar Koch <haegar@sdinet.de>
Subject: Re: [PATCH] ksm: Expose configuration via sysctl
In-Reply-To: <530D3102.60504@intel.com>
Message-ID: <alpine.DEB.2.10.1402261634010.31425@aurora64.sdinet.de>
References: <1393284484-27637-1-git-send-email-agraf@suse.de> <530CD443.7010400@intel.com> <4B3C0B08-45E1-48EF-8030-A3365F0E7CF6@suse.de> <530D3102.60504@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Alexander Graf <agraf@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>

On Tue, 25 Feb 2014, Dave Hansen wrote:

> On 02/25/2014 03:09 PM, Alexander Graf wrote:
> >> Couldn't we also (maybe in parallel) just teach the sysctl userspace
> >> about sysfs?  This way we don't have to do parallel sysctls and sysfs
> >> for *EVERYTHING* in the kernel:
> >>
> >>    sysfs.kernel.mm.transparent_hugepage.enabled=enabled
> > 
> > It's pretty hard to filter this. We definitely do not want to expose all of sysfs through /proc/sys. But how do we know which files are actual configuration and which ones are dynamic system introspection data?
> > 
> > We could add a filter, but then we can just as well stick with the manual approach I followed here :).
> 
> Maybe not stick it under /proc/sys, but teach sysctl(8) about them.  I
> guess at the moment, sysctl says that it's tied to /proc/sys:
> 
> > DESCRIPTION
> >        sysctl  is  used to modify kernel parameters at runtime.  The parameters available are those listed under /proc/sys/.  Procfs is required
> >        for sysctl support in Linux.  You can use sysctl to both read and write sysctl data.
> 
> But surely that's not set in stone just because the manpage says so. :)

What I still don't get is why you need this?

My distribution (Debian) has a sysfsutils package which provides a 
/etc/sysfs.conf / /etc/sysfs.d/foo exactly like /etc/sysctl.conf.

Don't other distributions have something like this?

c'ya
sven-haegar

-- 
Three may keep a secret, if two of them are dead.
- Ben F.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
