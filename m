Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 8098C6B0250
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 08:44:43 -0400 (EDT)
Date: Fri, 14 Sep 2012 22:45:04 +1000
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH 0/3] KVM: PPC: Book3S HV: More flexible allocator for
 linear memory
Message-ID: <20120914124504.GF15028@bloggs.ozlabs.ibm.com>
References: <20120912003427.GH32642@bloggs.ozlabs.ibm.com>
 <9650229C-2512-4684-98EC-6E252E47C4A9@suse.de>
 <20120914081140.GC15028@bloggs.ozlabs.ibm.com>
 <F7ED8384-5B23-478C-B2B7-927A3A755E98@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F7ED8384-5B23-478C-B2B7-927A3A755E98@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Graf <agraf@suse.de>
Cc: kvm-ppc@vger.kernel.org, KVM list <kvm@vger.kernel.org>, linux-mm@kvack.org, m.nazarewicz@samsung.com

On Fri, Sep 14, 2012 at 02:13:37PM +0200, Alexander Graf wrote:

> So do you think it makes more sense to reimplement a large page allocator in KVM, as this patch set does, or improve CMA to get us really big chunks of linear memory?
> 
> Let's ask the Linux mm guys too :). Maybe they have an idea.

I asked the authors of CMA, and apparently it's not limited to
MAX_ORDER as I feared.  It has the advantage that the memory can be
used for other things such as page cache when it's not needed, but not
for immovable allocations such as kmalloc.  I'm going to try it out.
It will need a patch to increase the maximum alignment it allows.

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
