Date: Tue, 14 Mar 2006 19:59:40 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: page migration: Fail with error if swap not setup
In-Reply-To: <20060314195234.10cf35a7.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0603141955370.24487@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603141903150.24199@schroedinger.engr.sgi.com>
 <20060314192443.0d121e73.akpm@osdl.org> <Pine.LNX.4.64.0603141945060.24395@schroedinger.engr.sgi.com>
 <20060314195234.10cf35a7.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 14 Mar 2006, Andrew Morton wrote:

> But the operation can still fail if we run out of swapspace partway through
> - so this problem can still occur.  The patch just makes it (much) less
> frequent.
> 
> Surely it's possible to communicate -ENOSWAP correctly and reliably?

There are a number of possible failure conditions. The strategy of the 
migration function is to migrate as much as possible and return the rest 
without giving any reason. migrate_pages() returns the number of leftover 
pages not the reasons they failed.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
