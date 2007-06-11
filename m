Date: Mon, 11 Jun 2007 09:23:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 15 of 16] limit reclaim if enough pages have been freed
In-Reply-To: <466C3A60.6080403@redhat.com>
Message-ID: <Pine.LNX.4.64.0706110922420.15489@schroedinger.engr.sgi.com>
References: <31ef5d0bf924fb47da14.1181332993@v2.random> <466C32F2.9000306@redhat.com>
 <20070610173221.GB7443@v2.random> <466C3A60.6080403@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, 10 Jun 2007, Rik van Riel wrote:

> Andrea Arcangeli wrote:
> > On Sun, Jun 10, 2007 at 01:20:50PM -0400, Rik van Riel wrote:
> > > code simultaneously, all starting out at priority 12 and
> > > not freeing anything until they all get to much lower
> > > priorities.
> > 
> > BTW, this reminds me that I've been wondering if 2**12 is a too small
> > fraction of the lru to start the scan with.
> 
> If the system has 1 TB of RAM, it's probably too big
> of a fraction :)
> 
> We need something smarter.

Well this value is depending on a nodes memory not on the systems 
total memory. So I think we are fine. 1TB systems (at least ours) are 
comprised of nodes with 4GB/8GB/16GB of memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
