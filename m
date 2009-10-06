Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1CB0B6B004D
	for <linux-mm@kvack.org>; Mon,  5 Oct 2009 20:05:05 -0400 (EDT)
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id n96050Gv029448
	for <linux-mm@kvack.org>; Tue, 6 Oct 2009 01:05:01 +0100
Received: from pxi13 (pxi13.prod.google.com [10.243.27.13])
	by spaceape9.eur.corp.google.com with ESMTP id n9604Cnj016893
	for <linux-mm@kvack.org>; Mon, 5 Oct 2009 17:04:58 -0700
Received: by pxi13 with SMTP id 13so3485635pxi.6
        for <linux-mm@kvack.org>; Mon, 05 Oct 2009 17:04:57 -0700 (PDT)
Date: Mon, 5 Oct 2009 17:04:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
In-Reply-To: <200910052334.23833.elendil@planet.nl>
Message-ID: <alpine.DEB.1.00.0910051700440.31688@chino.kir.corp.google.com>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <200910050851.02056.elendil@planet.nl> <20091005085739.GB5452@csn.ul.ie> <200910052334.23833.elendil@planet.nl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>
Cc: Mel Gorman <mel@csn.ul.ie>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 5 Oct 2009, Frans Pop wrote:

> And the winner is:
> 2ff05b2b4eac2e63d345fc731ea151a060247f53 is first bad commit
> commit 2ff05b2b4eac2e63d345fc731ea151a060247f53
> Author: David Rientjes <rientjes@google.com>
> Date:   Tue Jun 16 15:32:56 2009 -0700
> 
>     oom: move oom_adj value from task_struct to mm_struct
> 
> I'm confident that the bisection is good. The test case was very reliable 
> while zooming in on the merge from akpm.
> 

I doubt it for two reasons: (i) this commit was reverted in 0753ba0 since 
2.6.31-rc7 and is no longer in the kernel, and (ii) these are GFP_ATOMIC 
allocations which would be unaffected by oom killer scores.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
