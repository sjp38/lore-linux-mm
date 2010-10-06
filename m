Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 660566B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 12:25:04 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o96G8apW012318
	for <linux-mm@kvack.org>; Wed, 6 Oct 2010 12:08:36 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o96GP1td354332
	for <linux-mm@kvack.org>; Wed, 6 Oct 2010 12:25:01 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o96GP0Ej009558
	for <linux-mm@kvack.org>; Wed, 6 Oct 2010 13:25:01 -0300
Date: Wed, 6 Oct 2010 21:54:58 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 08/10] memcg: add cgroupfs interface to memcg dirty limits
Message-ID: <20101006162458.GJ4195@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
 <1286175485-30643-9-git-send-email-gthelen@google.com>
 <20101006133024.GE4195@balbir.in.ibm.com>
 <20101006133244.GF4195@balbir.in.ibm.com>
 <xr93pqvnjnq4.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <xr93pqvnjnq4.fsf@ninji.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* Greg Thelen <gthelen@google.com> [2010-10-06 09:21:55]:

> Looks good to me.  I am currently gather performance data on the memcg
> series.  It should be done in an hour or so.  I'll then repost V2 of the
> memcg dirty limits series.  I'll integrate this patch into the series,
> unless there's objection.
>

Please go ahead and incorporate it. Thanks! 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
