Date: Thu, 26 Jan 2006 09:57:45 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [patch 0/9] Critical Mempools
In-Reply-To: <1138217992.2092.0.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.62.0601260954540.15128@schroedinger.engr.sgi.com>
References: <1138217992.2092.0.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 25 Jan 2006, Matthew Dobson wrote:

> Using this new approach, a subsystem can create a mempool and then pass a
> pointer to this mempool on to all its slab allocations.  Anytime one of its
> slab allocations needs to allocate memory that memory will be allocated
> through the specified mempool, rather than through alloc_pages_node() directly.

All subsystems will now get more complicated by having to add this 
emergency functionality?

> Feedback on these patches (against 2.6.16-rc1) would be greatly appreciated.

There surely must be a better way than revising all subsystems for 
critical allocations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
