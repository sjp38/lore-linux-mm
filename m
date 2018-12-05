Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 20B906B7456
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 07:56:15 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id l45so9843242edb.1
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 04:56:15 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g25si1064513edu.428.2018.12.05.04.56.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 04:56:13 -0800 (PST)
Date: Wed, 5 Dec 2018 13:56:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC 0/7] mm: PG_reserved cleanups and documentation
Message-ID: <20181205125607.GM1286@dhcp22.suse.cz>
References: <20181205122851.5891-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181205122851.5891-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-m68k@lists.linux-m68k.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-mediatek@lists.infradead.org, Albert Ou <aou@eecs.berkeley.edu>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Anthony Yznaga <anthony.yznaga@oracle.com>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Bhupesh Sharma <bhsharma@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, Christophe Leroy <christophe.leroy@c-s.fr>, Dan Williams <dan.j.williams@intel.com>, Dave Kleikamp <dave.kleikamp@oracle.com>, David Airlie <airlied@linux.ie>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, James Morse <james.morse@arm.com>, Kees Cook <keescook@chromium.org>, Marc Zyngier <marc.zyngier@arm.com>, Mark Rutland <mark.rutland@arm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Matthew Wilcox <willy@infradead.org>, Michael Ellerman <mpe@ellerman.id.au>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Miles Chen <miles.chen@mediatek.com>, Palmer Dabbelt <palmer@sifive.com>, Paul Mackerras <paulus@samba.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Souptick Joarder <jrdr.linux@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Tobias Klauser <tklauser@distanz.ch>, Vasily Gorbik <gor@linux.ibm.com>, Will Deacon <will.deacon@arm.com>

On Wed 05-12-18 13:28:44, David Hildenbrand wrote:
[...]
> Most notably, for device memory we can hopefully soon stop setting
> it PG_reserved

I am busy as hell so I am not likely to look at specific patche this
week. But could you be more specific why we need to get rid of other
PG_reserved users before we can do so for device memory?

I am all for removing relicts because they just confuse people but I
fail to see any relation here.

-- 
Michal Hocko
SUSE Labs
