Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id F36DE5F0001
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 00:34:43 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp09.au.ibm.com (8.13.1/8.13.1) with ESMTP id n3G4EDHW018031
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 00:14:13 -0400
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3G4Z5CL385366
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 14:35:08 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3G4Z5mK029020
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 14:35:05 +1000
Date: Thu, 16 Apr 2009 10:04:26 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] Add file based RSS accounting for memory resource
	controller (v2)
Message-ID: <20090416043426.GF7082@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090415120510.GX7082@balbir.in.ibm.com> <20090416095303.b4106e9f.kamezawa.hiroyu@jp.fujitsu.com> <20090416015955.GB7082@balbir.in.ibm.com> <344eb09a0904152059w1a0ecfa4l6ff8c5f2130680ba@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <344eb09a0904152059w1a0ecfa4l6ff8c5f2130680ba@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Bharata B Rao <bharata.rao@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* Bharata B Rao <bharata.rao@gmail.com> [2009-04-16 09:29:53]:

> On Thu, Apr 16, 2009 at 7:29 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> >
> > Feature: Add file RSS tracking per memory cgroup
> >
> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> >
> > Changelog v3 -> v2
> > 1. Add corresponding put_cpu() for every get_cpu()
> >
> > Changelog v2 -> v1
> >
> > 1. Rename file_rss to mapped_file
> > 2. Add hooks into mem_cgroup_move_account for updating MAPPED_FILE statistics
> > 3. Use a better name for the statistics routine.
> >
> >
> > We currently don't track file RSS, the RSS we report is actually anon RSS.
> > All the file mapped pages, come in through the page cache and get accounted
> > there. This patch adds support for accounting file RSS pages. It should
> >
> > 1. Help improve the metrics reported by the memory resource controller
> > 2. Will form the basis for a future shared memory accounting heuristic
> >   that has been proposed by Kamezawa.
> >
> > Unfortunately, we cannot rename the existing "rss" keyword used in memory.stat
> > to "anon_rss". We however, add "mapped_file" data and hope to educate the end
> > user through documentation.
> >
> > Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> Balbir, could you please also update the documentation with the
> description about this new metric ?
>

Yes, I am going to in a follow up patch. I'll send that out after I do
some experimentation with shared memory size heuristics. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
