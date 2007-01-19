Date: Fri, 19 Jan 2007 10:27:43 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] nfs: fix congestion control
In-Reply-To: <1169231212.5775.29.camel@lade.trondhjem.org>
Message-ID: <Pine.LNX.4.64.0701191027260.15370@schroedinger.engr.sgi.com>
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com>
  <20070116135325.3441f62b.akpm@osdl.org> <1168985323.5975.53.camel@lappy>
 <Pine.LNX.4.64.0701171158290.7397@schroedinger.engr.sgi.com>
 <1169070763.5975.70.camel@lappy>  <1169070886.6523.8.camel@lade.trondhjem.org>
  <1169126868.6197.55.camel@twins>  <1169135375.6105.15.camel@lade.trondhjem.org>
  <1169199234.6197.129.camel@twins> <1169212022.6197.148.camel@twins>
 <Pine.LNX.4.64.0701190912540.14617@schroedinger.engr.sgi.com>
 <1169229461.6197.154.camel@twins> <1169231212.5775.29.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, 19 Jan 2007, Trond Myklebust wrote:

> That would be good as a default, but I've been thinking that we could
> perhaps also add a sysctl in /proc/sys/fs/nfs in order to make it a
> tunable?

Good idea.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
