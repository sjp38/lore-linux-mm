From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 2.6.17-rc1-mm1 0/6] Migrate-on-fault - Overview
Date: Tue, 11 Apr 2006 20:52:49 +0200
References: <1144441108.5198.36.camel@localhost.localdomain> <Pine.LNX.4.64.0604111134350.1027@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0604111134350.1027@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200604112052.50133.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, ak@suse.com
List-ID: <linux-mm.kvack.org>

On Tuesday 11 April 2006 20:46, Christoph Lameter wrote:
> However, if the page is not frequently references then the 
> effort required to migrate the page was not justified.

I have my doubts the whole thing is really worthwhile. It probably 
would at least need some statistics to only do this for frequent
accesses, but I don't know where to put this data.

At least it would be a serious research project to figure out 
a good way to do automatic migration. From what I was told by
people who tried this (e.g. in Irix) it is really hard and
didn't turn out to be a win for them.

The better way is to just provide the infrastructure
and let batch managers or program itselves take care of migration.

That was the whole idea behind NUMA API - some problems 
are too hard to figure out automatically by the kernel, so 
allow the user or application to give it a hand.

And frankly the defaults we have currently are not that bad,
perhaps with some small tweaks (e.g. i'm still liking the idea
of interleaving file cache by default) 

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
