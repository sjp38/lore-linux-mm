Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5EE948E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 10:38:45 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id j8so1859022plb.1
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 07:38:45 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e6si3553861pgp.504.2019.01.15.07.38.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 15 Jan 2019 07:38:44 -0800 (PST)
Date: Tue, 15 Jan 2019 07:38:39 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 0/9] mm: PG_reserved cleanups and documentation
Message-ID: <20190115153839.GE26443@infradead.org>
References: <20190114125903.24845-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190114125903.24845-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, Mark Rutland <mark.rutland@arm.com>, Michal Hocko <mhocko@suse.com>, CHANDAN VN <chandan.vn@samsung.com>, David Airlie <airlied@linux.ie>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Bhupesh Sharma <bhsharma@redhat.com>, Palmer Dabbelt <palmer@sifive.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Stefan Agner <stefan@agner.ch>, Michal Hocko <mhocko@kernel.org>, David Howells <dhowells@redhat.com>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-riscv@lists.infradead.org, Alexander Duyck <alexander.h.duyck@linux.intel.com>, linux-s390@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>, Vasily Gorbik <gor@linux.ibm.com>, Logan Gunthorpe <logang@deltatee.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Matthew Wilcox <willy@infradead.org>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Catalin Marinas <catalin.marinas@arm.com>, Anthony Yznaga <anthony.yznaga@oracle.com>, Tobias Klauser <tklauser@distanz.ch>, Laura Abbott <labbott@redhat.com>, Fenghua Yu <fenghua.yu@intel.com>, Albert Ou <aou@eecs.berkeley.edu>, Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>, Stephen Rothwell <sfr@canb.auug.org.au>, Marc Zyngier <marc.zyngier@arm.com>, Will Deacon <will.deacon@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, linux-m68k@lists.linux-m68k.org, Dave Kleikamp <dave.kleikamp@oracle.com>, linux-mediatek@lists.infradead.org, Oleg Nesterov <oleg@redhat.com>, Dan Williams <dan.j.williams@intel.com>, linux-arm-kernel@lists.infradead.org, Christophe Leroy <christophe.leroy@c-s.fr>, Matthias Brugger <mbrugger@suse.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org, Miles Chen <miles.chen@mediatek.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, James Morse <james.morse@arm.com>, Souptick Joarder <jrdr.linux@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Greg Hackmann <ghackmann@android.com>

On Mon, Jan 14, 2019 at 01:58:54PM +0100, David Hildenbrand wrote:
> Nothing major changed since the last version. I would be happy about
> additional ACKs. If there are no further comments, can this go via the
> mm-tree in one chunk?
> 
> I was recently going over all users of PG_reserved. Short story: it is
> difficult and sometimes not really clear if setting/checking for
> PG_reserved is only a relict from the past. Easy to break things. I
> guess I now have a pretty good idea wh things are like that
> nowadays and how they evolved.

Any reason you skipped

drivers/gpu/drm/drm_pci.c:drm_pci_alloc()

and 

drivers/gpu/drm/drm_scatter.c:drm_legacy_sg_alloc()

which both look completely bogus as-is?

In fact we should probably just try to kill them off as they have
very few users left.
