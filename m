Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C6FAF8D0017
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 21:03:53 -0500 (EST)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id oAF21TY6021396
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 19:01:29 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oAF23ha1152190
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 19:03:43 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oAF23h1x012886
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 19:03:43 -0700
Date: Mon, 15 Nov 2010 07:33:30 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH] Make swap accounting default behavior configurable v2
Message-ID: <20101115020330.GB9882@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20101110125154.GC5867@tiehlicka.suse.cz>
 <20101111094613.eab2ec0b.nishimura@mxp.nes.nec.co.jp>
 <20101111093155.GA20630@tiehlicka.suse.cz>
 <20101112094118.b02b669f.nishimura@mxp.nes.nec.co.jp>
 <20101112083103.GB7285@tiehlicka.suse.cz>
 <20101115101335.8880fd87.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20101115101335.8880fd87.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2010-11-15 10:13:35]:

Thanks Nishimura-San

It seems like the motivation for the patch is to allow distros to
enable memory cgroups and swap control, but to have swap control
turned off by default (because we provide default on today)
 - is my understanding correct?

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
