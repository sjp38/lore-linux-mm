Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 23824600044
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 18:12:10 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o6QMC7aF002470
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 15:12:07 -0700
Received: from pzk6 (pzk6.prod.google.com [10.243.19.134])
	by kpbe11.cbf.corp.google.com with ESMTP id o6QMC5Ro032337
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 15:12:06 -0700
Received: by pzk6 with SMTP id 6so1588436pzk.31
        for <linux-mm@kvack.org>; Mon, 26 Jul 2010 15:12:05 -0700 (PDT)
Date: Mon, 26 Jul 2010 15:12:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: PROBLEM: oom killer and swap weirdness on 2.6.3* kernels
In-Reply-To: <AANLkTikUO+WMHXqTMc7jR84UMgKidzX5d5JX6q=DvmpY@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1007261510320.2993@chino.kir.corp.google.com>
References: <AANLkTimAF1zxXlnEavXSnlKTkQgGD0u9UqCtUVT_r9jV@mail.gmail.com> <AANLkTimUYmUCdFMIaVi1qqcz2DqGoILeu43XWZBHSILP@mail.gmail.com> <AANLkTilmr29Vv3N64n7KVj9fSDpfBHIt8-quxtEwY0_X@mail.gmail.com> <alpine.LSU.2.00.1005211410170.14789@sister.anvils>
 <AANLkTil8sEzrsC9If5HdU8S5R-sK84_fUt_BXUDcAu0J@mail.gmail.com> <alpine.DEB.2.00.1006011351400.13136@chino.kir.corp.google.com> <AANLkTikUO+WMHXqTMc7jR84UMgKidzX5d5JX6q=DvmpY@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: dave b <db.pub.mail@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Jul 2010, dave b wrote:

> Actually it turns out on 2.6.34.1 I can trigger this issue. What it
> really is, is that linux doesn't invoke the oom killer when it should
> and kill something off. This is *really* annoying.
> 

I'm not exactly sure what you're referring to, it's been two months and 
you're using a new kernel and now you're saying that the oom killer isn't 
being utilized when the original problem statement was that it was killing 
things inappropriately?

> I used the follow script - (on 2.6.34.1)
> cat ./scripts/disable_over_commit
> #!/bin/bash
> echo 2 > /proc/sys/vm/overcommit_memory
> echo 40 > /proc/sys/vm/dirty_ratio
> echo 5 > /proc/sys/vm/dirty_background_ratio
> 
> And I was still able to reproduce this bug.
> Here is some c  code to trigger the condition I am talking about.
> 
> 
> #include <stdlib.h>
> #include <stdio.h>
> 
> int main(void)
> {
> 	while(1)
> 	{
> 		malloc(1000);
> 	}
> 
> 	return 0;
> }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
