Date: Sun, 23 Dec 2007 20:11:49 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 00/20] VM pageout scalability improvements
Message-ID: <20071223201149.7b88888f@bree.surriel.com>
In-Reply-To: <476EE858.202@linux.vnet.ibm.com>
References: <20071218211539.250334036@redhat.com>
	<476D7334.4010301@linux.vnet.ibm.com>
	<20071222192119.030f32d5@bree.surriel.com>
	<476EE858.202@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Mon, 24 Dec 2007 04:29:36 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> Rik van Riel wrote:

> > In the real world, users with large JVMs on their servers, which
> > sometimes go a little into swap, can trigger this system.  All of
> > the CPUs end up scanning the active list, and all pages have the
> > referenced bit set.  Even if the system eventually recovers, it
> > might as well have been dead.
> > 
> > Going into swap a little should only take a little bit of time.
> 
> Very fascinating, so we need to scale better with larger memory.
> I suspect part of the answer will lie with using large/huge pages.

Linus vetoed going to a larger soft page size, with good reason.

Just look at how much the 64kB page size on PPC64 sucks for most
workloads - it works for PPC64 because people buy PPC64 monster
systems for the kinds of monster workloads that work well with a
large page size, but it definately isn't general purpose.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
