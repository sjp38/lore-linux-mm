Message-ID: <48A97F76.7060201@linux-foundation.org>
Date: Mon, 18 Aug 2008 08:56:06 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [BUG] linux-next: Tree for August 11/12 - powerpc - oops at __kmalloc_node_track_caller
 ()
References: <20080812185345.d7496513.sfr@canb.auug.org.au> <48A1C924.6020000@linux.vnet.ibm.com> <48A1D65A.8000600@linux-foundation.org> <48A75E72.7050508@linux.vnet.ibm.com>
In-Reply-To: <48A75E72.7050508@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Kamalesh Babulal wrote:
> C
> Unable to handle kernel paging request for data at address 0x6b6b6b6b6b6b6be3

A pointer was dereferenced in an object that was already freed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
