Date: Fri, 30 Sep 2005 19:46:31 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH] per-page SLAB freeing (only dcache for now)
In-Reply-To: <20050930193754.GB16812@xeon.cnet>
Message-ID: <Pine.LNX.4.62.0509301934390.31011@schroedinger.engr.sgi.com>
References: <20050930193754.GB16812@xeon.cnet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org, akpm@osdl.org, dgc@sgi.com, dipankar@in.ibm.com, mbligh@mbligh.org, manfred@colorfullife.com
List-ID: <linux-mm.kvack.org>

On Fri, 30 Sep 2005, Marcelo wrote:

> I don't see any fundamental problems with this approach, are there any?
> I'll clean it up and proceed to write the inode cache equivalent 
> if there aren't.

Hmm. I think this needs to be some generic functionality in the slab 
allocator. If the allocator determines that the number of entries in a 
page become reasonably low then call a special function provided at 
slab creation time to try to free up the leftover entries.

Something like

int slab_try_free(void *);

?

return true/false depending on success of attempt to free the entry.

This method may also be useful to attempt to migrate slab pages to 
different nodes. If such a method is available then one can try to free 
all entries in a page relying on their recreation on another node if they 
are needed again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
