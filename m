Date: Mon, 2 Apr 2007 09:18:16 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
In-Reply-To: <200704011246.52238.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0704020914280.30634@schroedinger.engr.sgi.com>
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>
 <20070401071029.23757.78021.sendpatchset@schroedinger.engr.sgi.com>
 <200704011246.52238.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Sun, 1 Apr 2007, Andi Kleen wrote:

> Or do you have overlaps with other memory (I think you have)

We may get into a case where some page structs are physically located
on other nodes if there are no holes between nodes. This would be 
particularly significant for 64MB node sizes using numa emulation.
But there it really does not matter where the real memory is located.
(this is really inherent in sparsemems way of mapping memory).

> In that case you have to handle the overlap in change_page_attr()

Why would we use change_page_attr on page structs? I can see that the 
pages themselves should be subject to change_page_attr but why the 
page_structs? I think the system would panic if one would set page structs 
to read only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
