Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 920FC6B025F
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 10:57:56 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id d202so7983437lfd.11
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 07:57:56 -0700 (PDT)
Received: from tartarus.angband.pl (tartarus.angband.pl. [2a03:9300:10::8])
        by mx.google.com with ESMTPS id s6si2492371lja.114.2017.08.30.07.57.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Aug 2017 07:57:54 -0700 (PDT)
Date: Wed, 30 Aug 2017 16:57:42 +0200
From: Adam Borowski <kilobyte@angband.pl>
Subject: Re: [PATCH 00/13] mmu_notifier kill invalidate_page callback
Message-ID: <20170830145742.xird3lgsb3nemtye@angband.pl>
References: <20170829235447.10050-1-jglisse@redhat.com>
 <CA+55aFz6ArJ-ADXiYCu6xMUzdY=mKBtkzfJmLaBohC6Ub9t2SQ@mail.gmail.com>
 <20170830005615.GA2386@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170830005615.GA2386@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Bernhard Held <berny156@gmx.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Joerg Roedel <jroedel@suse.de>, Dan Williams <dan.j.williams@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Jack Steiner <steiner@sgi.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, ppc-dev <linuxppc-dev@lists.ozlabs.org>, DRI <dri-devel@lists.freedesktop.org>, amd-gfx@lists.freedesktop.org, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "open list:AMD IOMMU (AMD-VI)" <iommu@lists.linux-foundation.org>, xen-devel <xen-devel@lists.xenproject.org>, KVM list <kvm@vger.kernel.org>

On Tue, Aug 29, 2017 at 08:56:15PM -0400, Jerome Glisse wrote:
> I will wait for people to test and for result of my own test before
> reposting if need be, otherwise i will post as separate patch.
>
> > But from a _very_ quick read-through this looks fine. But it obviously
> > needs testing.
> > 
> > People - *especially* the people who saw issues under KVM - can you
> > try out JA(C)rA'me's patch-series? I aded some people to the cc, the full
> > series is on lkml. JA(C)rA'me - do you have a git branch for people to
> > test that they could easily pull and try out?
> 
> https://cgit.freedesktop.org/~glisse/linux mmu-notifier branch
> git://people.freedesktop.org/~glisse/linux

Tested your branch as of 10f07641, on a long list of guest VMs.
No earth-shattering kaboom.


Meow!
-- 
ac?aGBP'a  3/4 a >>ac?aGBP|a ? 
aGBP 3/4 a ?ac?a ?a ?aGBP?a!? Vat kind uf sufficiently advanced technology iz dis!?
ac?a!?a ?a .a ?a ?a ?                                 -- Genghis Ht'rok'din
a ?a 3aGBP?a ?a ?a ?a ? 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
