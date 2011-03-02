Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3DA748D0040
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 05:02:50 -0500 (EST)
Date: Wed, 2 Mar 2011 11:02:45 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] page_cgroup: Reduce allocation overhead for
 page_cgroup array for CONFIG_SPARSEMEM
Message-ID: <20110302100244.GB19651@tiehlicka.suse.cz>
References: <20110228100920.GD4648@tiehlicka.suse.cz>
 <20110301160550.0dd3217e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110301160550.0dd3217e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue 01-03-11 16:05:50, Andrew Morton wrote:
> On Mon, 28 Feb 2011 11:09:20 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > Hi Andrew,
> > could you consider the patch bellow, please?
> > The patch was discussed at https://lkml.org/lkml/2011/2/23/232
[...]
> This conflicts with
> memcg-remove-direct-page_cgroup-to-page-pointer.patch, which did

I have based my patch on top of the current Linus tree. Sorry about
that. Here is the patch rebased on top of the mmotm (2011-02-10-16-26).
The patch passes also checkpatch now.
--- 
