Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id B12376B0038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 10:29:34 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id tl7so2902707pab.2
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 07:29:34 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h77si5936307pfj.146.2015.12.16.07.29.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Dec 2015 07:29:33 -0800 (PST)
Date: Wed, 16 Dec 2015 07:29:23 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] include/linux/mmdebug.h: should include linux/bug.h
Message-Id: <20151216072923.5659b233.akpm@linux-foundation.org>
In-Reply-To: <56714AED.1060508@arm.com>
References: <1450110710-13486-1-git-send-email-james.morse@arm.com>
	<56714AED.1060508@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-mm@kvack.org, julien.grall@citrix.com

On Wed, 16 Dec 2015 11:28:45 +0000 James Morse <james.morse@arm.com> wrote:

> Hi Andrew,
> 
> Andrew Morton's robot wrote:
> > The patch titled
> >      Subject: include/linux/mmdebug.h: should include linux/bug.h
> > has been added to the -mm tree.  Its filename is
> >      include-linux-mmdebugh-should-include-linux-bugh.patch
> 
> > The -mm tree is included into linux-next and is updated
> > there every 3-4 working days
> 
> I'm unsure of your process for fixes - but could this be considered as a
> fix for 4.4-rc6?

The process for "wtf did Andrew do with my patch" is to look in
http://ozlabs.org/~akpm/mmots/series (which I update around 5PM PST on
US weekdays) and find the patch.

Today you'll see

#NEXT_PATCHES_START mainline-urgent
proc-fix-esrch-error-when-writing-to-proc-pid-coredump_filter.patch
mm-zswap-change-incorrect-strncmp-use-to-strcmp.patch
include-linux-mmdebugh-should-include-linux-bugh.patch

so yup, it's head-of-queue and I'll send it Linuswards probably
tomorrow.  Or maybe today.

> This problem was exposed by a fix merged for 4.4-rc5, and is currently
> breaking the build of arm64 with XEN [0] or the mantis pci driver[1].
> 
> Sorry if this wasn't clear from the commit message...

It helps a lot when commit messages explain the seriousness/impact of
the bug.  But fixes for build errors are so self-explanatory, even I can
understand them ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
