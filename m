Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3DE7A6B025F
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 04:40:37 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l19so1461734wmi.1
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 01:40:37 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.20])
        by mx.google.com with ESMTPS id j64si2739695wmd.63.2017.08.30.01.40.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 01:40:36 -0700 (PDT)
Message-ID: <1504082414.6014.39.camel@gmx.de>
Subject: Re: [PATCH 00/13] mmu_notifier kill invalidate_page callback
From: Mike Galbraith <efault@gmx.de>
Date: Wed, 30 Aug 2017 10:40:14 +0200
In-Reply-To: <20170830005615.GA2386@redhat.com>
References: <20170829235447.10050-1-jglisse@redhat.com>
	 <CA+55aFz6ArJ-ADXiYCu6xMUzdY=mKBtkzfJmLaBohC6Ub9t2SQ@mail.gmail.com>
	 <20170830005615.GA2386@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Joerg Roedel <jroedel@suse.de>, Dan Williams <dan.j.williams@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Jack Steiner <steiner@sgi.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?UTF-8?Q?Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, ppc-dev <linuxppc-dev@lists.ozlabs.org>, DRI <dri-devel@lists.freedesktop.org>, amd-gfx@lists.freedesktop.org, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "open list:AMD
 IOMMU (AMD-VI)" <iommu@lists.linux-foundation.org>, xen-devel <xen-devel@lists.xenproject.org>, KVM list <kvm@vger.kernel.org>

On Tue, 2017-08-29 at 20:56 -0400, Jerome Glisse wrote:
> On Tue, Aug 29, 2017 at 05:11:24PM -0700, Linus Torvalds wrote:
>=20
> > People - *especially* the people who saw issues under KVM - can you
> > try out J=C3=A9r=C3=B4me's patch-series? I aded some people to the cc, =
the full
> > series is on lkml. J=C3=A9r=C3=B4me - do you have a git branch for peop=
le to
> > test that they could easily pull and try out?
>=20
> https://cgit.freedesktop.org/~glisse/linux mmu-notifier branch
> git://people.freedesktop.org/~glisse/linux

Looks good here.

I reproduced fairly quickly with RT host and 1 RT guest by just having
the guest do a parallel kbuild over NFS (the guest had to be restored
afterward, was corrupted). =C2=A0I'm currently flogging 2 guests as well as
the host, whimper free. =C2=A0I'll let the lot broil for while longer, but
at this point, smoke/flame appearance seems comfortingly unlikely.

	-Mike


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
