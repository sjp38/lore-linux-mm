Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3797F6B004D
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 12:35:21 -0400 (EDT)
Date: Fri, 10 Jul 2009 09:54:10 -0700 (PDT)
From: "Li, Ming Chun" <macli@brc.ubc.ca>
Subject: Re: [PATCH 0/5] OOM analysis helper patch series v2
In-Reply-To: <20090710111241.17DE.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.00.0907100951390.27807@mail.selltech.ca>
References: <alpine.DEB.1.00.0907091502450.25351@mail.selltech.ca> <20090710083407.17BE.A69D9226@jp.fujitsu.com> <20090710111241.17DE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 10 Jul 2009, KOSAKI Motohiro wrote:

> > > On Thu, 9 Jul 2009, Li, Ming Chun wrote:
> > > 
> > > I am applying the patch series to 2.6.31-rc2.
> > 
> > hm, maybe I worked on a bit old tree. I will check latest linus tree again
> > today.
> > 
> > thanks.
> 
> I checked my patch on 2.6.31-rc2. but I couldn't reproduce your problem.
> 
> But, I recognize my fault.
> This patch series depend on "[PATCH] Makes slab pages field in show_free_areas() separate two field"
> patch. (it was posted at "Jul 30").
> Can you please apply it at first?
> 
> Or, can you use mmotm tree?
> 

Ok, I tried mmotm tree, The patches were applied cleanly, Thanks.

Vincent Li
Biomedical Research Center
University of British Columbia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
