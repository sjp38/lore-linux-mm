Date: Thu, 3 May 2007 01:07:44 -0500
From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH] Fix hugetlb pool allocation with empty nodes
Message-ID: <20070503060744.GA13015@kryten>
References: <20070503022107.GA13592@kryten> <Pine.LNX.4.64.0705021959100.4259@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705021959100.4259@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, ak@suse.de, nish.aravamudan@gmail.com, mel@csn.ul.ie, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

 
Hi,

> > Im guessing registering empty remote zones might make the SGI guys a bit
> > unhappy, maybe we should just force the registration of empty local
> > zones? Does anyone care?
> 
> Why would that make us unhappy?

Since SGI boxes can have lots of NUMA nodes I was worried the patch
might negatively affect you. It sounds like thats not so much of an
issue.

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
