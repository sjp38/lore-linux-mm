Date: Wed, 15 Mar 2006 10:10:26 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC] AutoPage Migration - V0.1 - 0/8 Overview
In-Reply-To: <20060315095426.b70026b8.pj@sgi.com>
Message-ID: <Pine.LNX.4.64.0603151008570.27212@schroedinger.engr.sgi.com>
References: <1142019195.5204.12.camel@localhost.localdomain>
 <20060311154113.c4358e40.kamezawa.hiroyu@jp.fujitsu.com>
 <1142270857.5210.50.camel@localhost.localdomain>
 <Pine.LNX.4.64.0603131541330.13713@schroedinger.engr.sgi.com>
 <44183B64.3050701@argo.co.il> <20060315095426.b70026b8.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Avi Kivity <avi@argo.co.il>, lee.schermerhorn@hp.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Mar 2006, Paul Jackson wrote:

> > Doesn't it make sense to duplicate heavily accessed shared read-only pages?
> 
> It might .. that would be a major and difficult effort,
> and it is not clear that it would be a win.  The additional
> bookkeeping to figure out what pages were heavily accessed
> would be very costly.  Probably prohibitive.
> 
> That's certainly a very different discussion than migration.

That is a different discussion but it is not complicated. There are 
trivial one or two line patches around that make the fault handlers copy 
a page if a certain mapcount is reached.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
