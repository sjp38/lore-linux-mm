Subject: [RFC][PATCH 0/6] Sparsemem: chop up the global mem_map[]
From: Dave Hansen <dave@sr71.net>
Content-Type: text/plain
Date: Wed, 16 Mar 2005 16:27:45 -0800
Message-Id: <1111019265.19021.15.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-arch@vger.kernel.org
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

The following patch set implements a feature we call sparsemem: sparse
memory handling.

Sparsemem is more flexible than discontig (what we usually use for NUMA
machines), not tied to any existing NUMA or MM structures like zones or
pgdats, and can handle layouts that discontig can not.  That makes it
ideal for memory hotplug where those structures are going to be coming
and going, sliced and diced.  The current memory hotplug implementation
depends on sparsemem.

For more description, see the [PATCH 1/6] in this set, or this thread:

	http://marc.theaimsgroup.com/?l=linux-mm&m=111085907830087&w=2

I'd like to send these patches into -mm for a long soak, in a week or
two.  I wanted to provide everyone another opportunity to comment before
that.

As I say in the first patch, changes necessary to make this work with
architectures other than i386 will be going to the individual
maintainers for approval before -mm.  If you're an arch maintainer
(ppc64, ia64, x86-64), and you wonder what the changes for your arch
look like, please see the B-sparse-...<your_arch>.patch in 

	http://sr71.net/patches/2.6.11/2.6.11-bk7-mhp1/broken-out/

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
