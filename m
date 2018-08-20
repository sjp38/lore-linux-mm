Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id C22E66B17EC
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 03:37:57 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id 40-v6so12196218wrb.23
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 00:37:57 -0700 (PDT)
Received: from relay8-d.mail.gandi.net (relay8-d.mail.gandi.net. [217.70.183.201])
        by mx.google.com with ESMTPS id o2-v6si2253157wrq.63.2018.08.20.00.37.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 20 Aug 2018 00:37:56 -0700 (PDT)
Subject: Re: [PATCH v6 00/11] hugetlb: Factorize hugetlb architecture
 primitives
References: <20180806175711.24438-1-alex@ghiti.fr>
 <81078a7f-09cf-7f19-f6bb-8a1f4968d6fb@ghiti.fr>
 <20180820071730.GC29735@dhcp22.suse.cz>
From: Alexandre Ghiti <alex@ghiti.fr>
Message-ID: <00b8c047-3ab5-f86b-41e5-d87950f10c21@ghiti.fr>
Date: Mon, 20 Aug 2018 09:36:35 +0200
MIME-Version: 1.0
In-Reply-To: <20180820071730.GC29735@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, tony.luck@intel.com, fenghua.yu@intel.com, ralf@linux-mips.org, paul.burton@mips.com, jhogan@kernel.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, arnd@arndb.de, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

Ok, my bad, sorry about that, I have just added Andrew as CC then.

Thank you,

Alex


On 08/20/2018 09:17 AM, Michal Hocko wrote:
> On Mon 20-08-18 08:45:10, Alexandre Ghiti wrote:
>> Hi Michal,
>>
>> This patchset got acked, tested and reviewed by quite a few people, and it
>> has been suggested
>> that it should be included in -mm tree: could you tell me if something else
>> needs to be done for
>> its inclusion ?
>>
>> Thanks for your time,
> I didn't really get to look at the series but seeing an Ack from Mike
> and arch maintainers should be good enough for it to go. This email
> doesn't have Andrew Morton in the CC list so you should add him if you
> want the series to land into the mm tree.
