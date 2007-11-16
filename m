Date: Thu, 15 Nov 2007 18:52:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: x86_64: Make sparsemem/vmemmap the default memory model
Message-Id: <20071115185254.1177cede.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0711151824310.31691@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0711121549370.29178@schroedinger.engr.sgi.com>
	<200711130059.34346.ak@suse.de>
	<Pine.LNX.4.64.0711121615120.29328@schroedinger.engr.sgi.com>
	<200711130149.54852.ak@suse.de>
	<Pine.LNX.4.64.0711121940410.30269@schroedinger.engr.sgi.com>
	<20071115141212.acb215f1.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0711151824310.31691@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie, ak@suse.de, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Nov 2007 18:24:54 -0800 (PST) Christoph Lameter <clameter@sgi.com> wrote:

> On Thu, 15 Nov 2007, Andrew Morton wrote:
> 
> > Unfortunately some loon has gone and merged the i386 and x86_64 Kconfig
> > files.  I was fixing that up but I worry what effects these Kconfig changes
> > might have on, for example, i386 NUMA setups.
> > 
> > So I'll duck this version, sorry.
> 
> Is there a tree that I can rediff the patch against?

Mainline.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
