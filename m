Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5508C8E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 06:36:59 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id k203so19070103qke.2
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:36:59 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s7si4100410qvr.49.2019.01.21.03.36.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 03:36:58 -0800 (PST)
Subject: Re: [PATCH v2 0/9] mm: PG_reserved cleanups and documentation
References: <20190114125903.24845-1-david@redhat.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <6abb9ad2-f103-12a2-e1dc-eec81b801338@redhat.com>
Date: Mon, 21 Jan 2019 12:36:35 +0100
MIME-Version: 1.0
In-Reply-To: <20190114125903.24845-1-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-m68k@lists.linux-m68k.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-mediatek@lists.infradead.org, AKASHI Takahiro <takahiro.akashi@linaro.org>, Albert Ou <aou@eecs.berkeley.edu>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, Anthony Yznaga <anthony.yznaga@oracle.com>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Bhupesh Sharma <bhsharma@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, CHANDAN VN <chandan.vn@samsung.com>, Christophe Leroy <christophe.leroy@c-s.fr>, Dan Williams <dan.j.williams@intel.com>, Dave Kleikamp <dave.kleikamp@oracle.com>, David Airlie <airlied@linux.ie>, David Howells <dhowells@redhat.com>, Fenghua Yu <fenghua.yu@intel.com>, Florian Fainelli <f.fainelli@gmail.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Hackmann <ghackmann@android.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, James Morse <james.morse@arm.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Kristina Martsenko <kristina.martsenko@arm.com>, Laura Abbott <labbott@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Marc Zyngier <marc.zyngier@arm.com>, Mark Rutland <mark.rutland@arm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Matthew Wilcox <willy@infradead.org>, Matthias Brugger <mbrugger@suse.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Miles Chen <miles.chen@mediatek.com>, Oleg Nesterov <oleg@redhat.com>, Palmer Dabbelt <palmer@sifive.com>, Paul Mackerras <paulus@samba.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Randy Dunlap <rdunlap@infradead.org>, Souptick Joarder <jrdr.linux@gmail.com>, Stefan Agner <stefan@agner.ch>, Stephen Rothwell <sfr@canb.auug.org.au>, Tobias Klauser <tklauser@distanz.ch>, Tony Luck <tony.luck@intel.com>, Vasily Gorbik <gor@linux.ibm.com>, Will Deacon <will.deacon@arm.com>

On 14.01.19 13:58, David Hildenbrand wrote:
> Nothing major changed since the last version. I would be happy about
> additional ACKs. If there are no further comments, can this go via the
> mm-tree in one chunk?

For the time being, I will not add further patches to this series (as
discussed in response to one question, we have to be careful dropping
PG_reserved at some places). Only ACKs were added during review so far.

@Andrew, how to proceed with this?

-- 

Thanks,

David / dhildenb
