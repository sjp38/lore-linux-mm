Date: Tue, 16 Jan 2007 11:14:22 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/29] Page Table Interface Explanation
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Message-ID: <Pine.LNX.4.64.0701161112280.6637@schroedinger.engr.sgi.com>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Davies <pauld@gelato.unsw.edu.au>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

One important thing to note here is that the abstraction of the page table 
goes way beyond the needs for other page table formats.

Think about virtualization technologies such as VMware, Xen and KVM. If 
those can implement an alternate page table update mechanism then we do 
not need many of the hooks that are currently being proposed. There is the 
potential that we can come up with forms of page tables that avoid the 
current issues with shadow page tables.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
