Date: Thu, 25 Jan 2007 22:04:57 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] nfs: fix congestion control -v4
Message-Id: <20070125220457.a761ae6a.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0701252130500.7147@schroedinger.engr.sgi.com>
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com>
	<20070116135325.3441f62b.akpm@osdl.org>
	<1168985323.5975.53.camel@lappy>
	<Pine.LNX.4.64.0701171158290.7397@schroedinger.engr.sgi.com>
	<1169070763.5975.70.camel@lappy>
	<1169070886.6523.8.camel@lade.trondhjem.org>
	<1169126868.6197.55.camel@twins>
	<1169135375.6105.15.camel@lade.trondhjem.org>
	<1169199234.6197.129.camel@twins>
	<1169212022.6197.148.camel@twins>
	<Pine.LNX.4.64.0701190912540.14617@schroedinger.engr.sgi.com>
	<1169229461.6197.154.camel@twins>
	<1169231212.5775.29.camel@lade.trondhjem.org>
	<1169276500.6197.159.camel@twins>
	<1169482343.6083.7.camel@lade.trondhjem.org>
	<1169739148.6189.68.camel@twins>
	<20070125210950.bcdaa7f6.akpm@osdl.org>
	<Pine.LNX.4.64.0701252130500.7147@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 25 Jan 2007 21:31:43 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Thu, 25 Jan 2007, Andrew Morton wrote:
> 
> > atomic_t is 32-bit.  Put 16TB of memory under writeback and blam.
> 
> We have systems with 8TB main memory and are able to get to 16TB.

But I bet you don't use 4k pages on 'em ;)

> Better change it now.

yup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
