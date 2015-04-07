Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id DA94D6B0070
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 19:36:16 -0400 (EDT)
Received: by pdea3 with SMTP id a3so94691416pde.3
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 16:36:16 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ez9si13705726pdb.222.2015.04.07.16.36.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Apr 2015 16:36:16 -0700 (PDT)
Date: Tue, 7 Apr 2015 16:36:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/migrate: Mark unmap_and_move() "noinline" to avoid
 ICE in gcc 4.7.3
Message-Id: <20150407163614.1f0ec880cecd681dcd271295@linux-foundation.org>
In-Reply-To: <7hiod7o6xb.fsf@deeprootsystems.com>
References: <20150324004537.GA24816@verge.net.au>
	<CAKv+Gu-0jPk=KQ4gY32ELc+BVbe=1QdcrwQ+Pb=RkdwO9K3Vkw@mail.gmail.com>
	<20150324161358.GA694@kahuna>
	<20150326003939.GA25368@verge.net.au>
	<20150326133631.GB2805@arm.com>
	<CANMBJr68dsbYvvHUzy6U4m4fEM6nq8dVHBH4kLQ=0c4QNOhLPQ@mail.gmail.com>
	<20150327002554.GA5527@verge.net.au>
	<20150327100612.GB1562@arm.com>
	<7hbnj99epe.fsf@deeprootsystems.com>
	<CAKv+Gu_ZHZFm-1eXn+r7fkEHOxqSmj+Q+Mmy7k6LK531vSfAjQ@mail.gmail.com>
	<7h8uec95t2.fsf@deeprootsystems.com>
	<alpine.DEB.2.10.1504011130030.14762@ayla.of.borg>
	<551BBEC5.7070801@arm.com>
	<20150401124007.20c440cc43a482f698f461b8@linux-foundation.org>
	<7hwq1v4iq4.fsf@deeprootsystems.com>
	<CAMAWPa_YEJDQc=_60_sPqzwLYN8Yefzcko_rydxrt8oOCq20gw@mail.gmail.com>
	<20150407131740.ac8a856537fecb1b5d142f5f@linux-foundation.org>
	<7hpp7fo92b.fsf@deeprootsystems.com>
	<20150407155310.a3e9dfb6d929a968c4bfc286@linux-foundation.org>
	<7hiod7o6xb.fsf@deeprootsystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kevin Hilman <khilman@kernel.org>
Cc: Marc Zyngier <marc.zyngier@arm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <Will.Deacon@arm.com>, Simon Horman <horms@verge.net.au>, Tyler Baker <tyler.baker@linaro.org>, Nishanth Menon <nm@ti.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, Catalin Marinas <Catalin.Marinas@arm.com>, Magnus Damm <magnus.damm@gmail.com>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux Kernel Development <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 07 Apr 2015 16:27:44 -0700 Kevin Hilman <khilman@kernel.org> wrote:

> >> > It should all be there today?
> >> 
> >> Nope.  
> >
> > huh, I swear I did an mmotm yesterday.
> 
> Well, based on the timestamp of the mmotm dir on ozlabs, it appears you
> did.  That's why I was confused why the gcc-473 patches from mmots aren't
> there.

Things look a bit better now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
