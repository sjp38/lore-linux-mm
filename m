Date: Mon, 7 Apr 2003 00:15:48 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: subobj-rmap
Message-ID: <20030406221547.GP1326@dualathlon.random>
References: <Pine.LNX.4.44.0304061737510.2296-100000@chimarrao.boston.redhat.com> <1600000.1049666582@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1600000.1049666582@[10.10.2.4]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Rik van Riel <riel@surriel.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrew Morton <akpm@digeo.com>, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Bill Irwin <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On Sun, Apr 06, 2003 at 03:03:03PM -0700, Martin J. Bligh wrote:
> We can always leave the sys_remap_file_pages stuff using pte_chains,

not sure why you want still to have the vm to know about the
mmap(VM_NONLINEAR) hack at all.

that's a vm bypass. I can bet the people who wants to use it for running
faster on the the 32bit archs will definitely prefer zero overhead and
full hardware speed with only the pagetable and tlb flushing trash, and
zero additional kernel internal overhead. that's just a vm bypass that
could otherwise sit in kernel module, not a real kernel API.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
