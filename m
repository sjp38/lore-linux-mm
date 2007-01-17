Subject: Re: [PATCH] nfs: fix congestion control
From: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1169044186.22935.122.camel@twins>
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com>
	 <20070116135325.3441f62b.akpm@osdl.org>  <1168985323.5975.53.camel@lappy>
	 <1168986466.6056.52.camel@lade.trondhjem.org>
	 <1169001692.22935.84.camel@twins>
	 <1169014515.6065.5.camel@lade.trondhjem.org>
	 <1169023798.22935.96.camel@twins>
	 <1169041814.6102.3.camel@lade.trondhjem.org>
	 <1169044186.22935.122.camel@twins>
Content-Type: text/plain
Date: Wed, 17 Jan 2007 09:45:15 -0500
Message-Id: <1169045115.6102.20.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-01-17 at 15:29 +0100, Peter Zijlstra wrote:
> I was thinking that since the server needs to actually sync the page a
> commit might be quite expensive (timewise), hence I didn't want to flush
> too much, and interleave them with writing out some real pages to
> utilise bandwidth.

Most servers just call fsync()/fdatasync() whenever we send a COMMIT, in
which case the extra round trips are just adding unnecessary latency.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
