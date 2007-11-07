Date: Tue, 6 Nov 2007 18:23:44 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC PATCH 3/10] define page_file_cache
In-Reply-To: <20071103185516.24832ab0@bree.surriel.com>
Message-ID: <Pine.LNX.4.64.0711061821010.5249@schroedinger.engr.sgi.com>
References: <20071103184229.3f20e2f0@bree.surriel.com>
 <20071103185516.24832ab0@bree.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 3 Nov 2007, Rik van Riel wrote:

> Define page_file_cache() function to answer the question:
> 	is page backed by a file?

Well its not clear what is meant by a file in the first place.
By file you mean disk space in contrast to ram based filesystems?

I think we could add a flag to the bdi to indicate wheter the backing 
store is a disk file. In fact you can also deduce if if a device has
no writeback capability set in the BDI.

> Unfortunately this needs to use a page flag, since the
> PG_swapbacked state needs to be preserved all the way
> to the point where the page is last removed from the
> LRU.  Trying to derive the status from other info in
> the page resulted in wrong VM statistics in earlier
> split VM patchsets.

The bdi may avoid that extra flag.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
