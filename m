Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B8A006B002F
	for <linux-mm@kvack.org>; Fri, 28 Oct 2011 01:17:20 -0400 (EDT)
Received: by vws16 with SMTP id 16so4227266vws.14
        for <linux-mm@kvack.org>; Thu, 27 Oct 2011 22:17:18 -0700 (PDT)
Message-ID: <4EAA3ADC.4030501@vflare.org>
Date: Fri, 28 Oct 2011 01:17:16 -0400
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
In-Reply-To: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, levinsasha928@gmail.com, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Neo Jia <cyclonusj@gmail.com>

Hi Dan,

On 10/27/2011 02:52 PM, Dan Magenheimer wrote:

> Hi Linus --
> 
> Frontswap now has FOUR users: Two already merged in-tree (zcache
> and Xen) and two still in development but in public git trees
> (RAMster and KVM).  Frontswap is part 2 of 2 of the core kernel
> changes required to support transcendent memory; part 1 was cleancache
> which you merged at 3.0 (and which now has FIVE users).
>


I think frontswap would be really useful. Without this, zcache would be
limited to compressed caching just the page cache pages but with
frontswap, we can balance out compressed memory usage between swap cache
and page cache pages. It also provides many advantages over existing
solutions like zram which presents a fixed size virtual (compressed)
block device interface. Since fronstwap doesn't have to "pretend" as a
block device, it can incorporate many dynamic resizing policies, a
critical factor for compressed caching.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
