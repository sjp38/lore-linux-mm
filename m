Date: Tue, 8 May 2007 15:05:22 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Support concurrent local and remote frees and allocs on a slab.
In-Reply-To: <Pine.LNX.4.64.0705071753300.728@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0705081504270.15135@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705042025520.29006@schroedinger.engr.sgi.com>
 <20070507145030.9b7f41bd.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705071753300.728@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 7 May 2007, Christoph Lameter wrote:

> New rev. I tried to explain things better.

Please apply because this fixes the Clovertown performance 
regressions. So its was due to atomic overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
