Date: Mon, 4 Jun 2007 11:39:40 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 1/7] cpuset write dirty map
In-Reply-To: <465FB6CF.4090801@google.com>
Message-ID: <Pine.LNX.4.64.0706041138410.24412@schroedinger.engr.sgi.com>
References: <465FB6CF.4090801@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ethan Solomita <solo@google.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@google.com>, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

On Thu, 31 May 2007, Ethan Solomita wrote:

> The dirty map is only cleared (or freed) when the inode is cleared.
> At that point no pages are attached to the inode anymore and therefore it can
> be done without any locking. The dirty map therefore records all nodes that
> have been used for dirty pages by that inode until the inode is no longer
> used.
> 
> Originally by Christoph Lameter <clameter@sgi.com>

You should preserve my Signed-off-by: since I wrote most of this. Is there 
a changelog?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
