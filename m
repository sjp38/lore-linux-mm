Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2FB606B00CE
	for <linux-mm@kvack.org>; Sat, 13 Mar 2010 04:52:25 -0500 (EST)
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id o2D9qLtf024757
	for <linux-mm@kvack.org>; Sat, 13 Mar 2010 01:52:22 -0800
Received: from pxi3 (pxi3.prod.google.com [10.243.27.3])
	by spaceape11.eur.corp.google.com with ESMTP id o2D9qIDi013338
	for <linux-mm@kvack.org>; Sat, 13 Mar 2010 01:52:19 -0800
Received: by pxi3 with SMTP id 3so711598pxi.28
        for <linux-mm@kvack.org>; Sat, 13 Mar 2010 01:52:17 -0800 (PST)
Date: Sat, 13 Mar 2010 01:52:13 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mempolicy: remove redundant code
In-Reply-To: <1268456515-8557-1-git-send-email-user@bob-laptop>
Message-ID: <alpine.DEB.2.00.1003130149080.22823@chino.kir.corp.google.com>
References: <1268456515-8557-1-git-send-email-user@bob-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Sat, 13 Mar 2010, Bob Liu wrote:

> diff --git a/mempolicy.c b/mempolicy.c
> index bda230e..b6fbcbd 100644
> --- a/mempolicy.c
> +++ b/mempolicy.c

What git tree is this?  Your patch needs to change mm/mempolicy.c.

Please clone Linus' repository and then create a patch against that:

	git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
	cd linux-2.6
	<change mm/mempolicy.c>
	<compile, test>
	git commit -a
	git format-patch HEAD^

and send the .patch file.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
