Date: Wed, 15 Mar 2006 13:56:55 -0600
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH/RFC] AutoPage Migration - V0.1 - 0/8 Overview
Message-ID: <20060315195654.GA16771@sgi.com>
References: <1142019195.5204.12.camel@localhost.localdomain> <20060311154113.c4358e40.kamezawa.hiroyu@jp.fujitsu.com> <1142270857.5210.50.camel@localhost.localdomain> <Pine.LNX.4.64.0603131541330.13713@schroedinger.engr.sgi.com> <44183B64.3050701@argo.co.il> <20060315095426.b70026b8.pj@sgi.com> <Pine.LNX.4.64.0603151008570.27212@schroedinger.engr.sgi.com> <20060315101402.3b19330c.pj@sgi.com> <441863AC.6050101@argo.co.il> <1142450826.5198.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1142450826.5198.14.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Avi Kivity <avi@argo.co.il>, Paul Jackson <pj@sgi.com>, Christoph Lameter <clameter@sgi.com>, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, Steve Ofsthun <sofsthun@virtualiron.com>
List-ID: <linux-mm.kvack.org>

> > Is the kernel text duplicated?
> 
> No.  Might have been patches to do this for ia64 at one time.  I'm not
> sure, tho'.
> 

Yes, there is a patch to duplicate kernel text. I still have a copy
although I'm sure it has gotten very stale.

Kernel text replication was part of the IA64 "trillian" patch at 
one time but was dropped because we never saw any significant benefit.
However, systems are larger now & I would not be surprised if
replication helped on very large systems.

I plan to retest kernel replication within the next couple of
months. Stay tuned...

---
Jack




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
