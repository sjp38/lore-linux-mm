Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B51D5600044
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 22:36:58 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6R2MIII019432
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 22:22:18 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6R2atWk1613850
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 22:36:55 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6R2as4W013907
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 22:36:55 -0400
Subject: Re: [PATCH 4/8] v3 Allow memory_block to span multiple memory
 sections
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4C4A5985.6000206@austin.ibm.com>
References: <4C451BF5.50304@austin.ibm.com>
	 <4C451E1C.8070907@austin.ibm.com> <1279653481.9785.4.camel@nimitz>
	 <4C4A5985.6000206@austin.ibm.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Mon, 26 Jul 2010 19:36:52 -0700
Message-ID: <1280198212.16922.422.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, greg@kroah.com
List-ID: <linux-mm.kvack.org>

On Fri, 2010-07-23 at 22:09 -0500, Nathan Fontenot wrote:
> If we add a lock should I submit it as part of this patchset? or
> submit it
> as a follow-on?

It should probably be at the beginning of the patch set.  We don't want
to have a case where your set introduces races that we _need_ a later
patch to fix.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
