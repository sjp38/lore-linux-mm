Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3667A6B0263
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 06:29:41 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id ur14so22418064pab.0
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 03:29:41 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id qv6si8899179pab.124.2015.12.16.03.29.40
        for <linux-mm@kvack.org>;
        Wed, 16 Dec 2015 03:29:40 -0800 (PST)
Message-ID: <56714AED.1060508@arm.com>
Date: Wed, 16 Dec 2015 11:28:45 +0000
From: James Morse <james.morse@arm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] include/linux/mmdebug.h: should include linux/bug.h
References: <1450110710-13486-1-git-send-email-james.morse@arm.com>
In-Reply-To: <1450110710-13486-1-git-send-email-james.morse@arm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, julien.grall@citrix.com

Hi Andrew,

Andrew Morton's robot wrote:
> The patch titled
>      Subject: include/linux/mmdebug.h: should include linux/bug.h
> has been added to the -mm tree.  Its filename is
>      include-linux-mmdebugh-should-include-linux-bugh.patch

> The -mm tree is included into linux-next and is updated
> there every 3-4 working days

I'm unsure of your process for fixes - but could this be considered as a
fix for 4.4-rc6?

This problem was exposed by a fix merged for 4.4-rc5, and is currently
breaking the build of arm64 with XEN [0] or the mantis pci driver[1].

Sorry if this wasn't clear from the commit message...


Thanks,

James

[0] https://lkml.org/lkml/2015/12/14/489
[1] https://lkml.org/lkml/2015/12/15/910

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
