Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0E9B76B17B8
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 03:17:36 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id t24-v6so5606812edq.13
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 00:17:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t18-v6si2036686edf.80.2018.08.20.00.17.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Aug 2018 00:17:34 -0700 (PDT)
Date: Mon, 20 Aug 2018 09:17:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6 00/11] hugetlb: Factorize hugetlb architecture
 primitives
Message-ID: <20180820071730.GC29735@dhcp22.suse.cz>
References: <20180806175711.24438-1-alex@ghiti.fr>
 <81078a7f-09cf-7f19-f6bb-8a1f4968d6fb@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <81078a7f-09cf-7f19-f6bb-8a1f4968d6fb@ghiti.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, tony.luck@intel.com, fenghua.yu@intel.com, ralf@linux-mips.org, paul.burton@mips.com, jhogan@kernel.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, arnd@arndb.de, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org

On Mon 20-08-18 08:45:10, Alexandre Ghiti wrote:
> Hi Michal,
> 
> This patchset got acked, tested and reviewed by quite a few people, and it
> has been suggested
> that it should be included in -mm tree: could you tell me if something else
> needs to be done for
> its inclusion ?
> 
> Thanks for your time,

I didn't really get to look at the series but seeing an Ack from Mike
and arch maintainers should be good enough for it to go. This email
doesn't have Andrew Morton in the CC list so you should add him if you
want the series to land into the mm tree.
-- 
Michal Hocko
SUSE Labs
