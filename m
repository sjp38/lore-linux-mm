Date: Wed, 23 May 2007 21:06:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 10/16] Variable Order Page Cache: Readahead fixups
In-Reply-To: <379979481.69222@ustc.edu.cn>
Message-ID: <Pine.LNX.4.64.0705232105470.24495@schroedinger.engr.sgi.com>
References: <20070423064845.5458.2190.sendpatchset@schroedinger.engr.sgi.com>
 <20070423064937.5458.59638.sendpatchset@schroedinger.engr.sgi.com>
 <20070425113613.GF19942@skynet.ie> <Pine.LNX.4.64.0704250854420.24530@schroedinger.engr.sgi.com>
 <379744113.16390@ustc.edu.cn> <Pine.LNX.4.64.0705210947450.25871@schroedinger.engr.sgi.com>
 <379979481.69222@ustc.edu.cn>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Fengguang Wu <fengguang.wu@gmail.com>
Cc: Mel Gorman <mel@skynet.ie>, linux-mm@kvack.org, William Lee Irwin III <wli@holomorphy.com>, Badari Pulavarty <pbadari@gmail.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Adam Litke <aglitke@gmail.com>, Dave Hansen <hansendc@us.ibm.com>, Avi Kivity <avi@argo.co.il>
List-ID: <linux-mm.kvack.org>

On Thu, 24 May 2007, Fengguang Wu wrote:

> So we do not want to enforce a maximum page size.
> The patch is updated to only decrease the readahead pages on increased
> page size, until it falls to 1. If page size continues to increase,
> the I/O size will increase anyway.

Ahh Great! I will put that into the next rollup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
