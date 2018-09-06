Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 854966B78E1
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 09:30:37 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w12-v6so12654792oie.12
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 06:30:37 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e67-v6si3171679oia.360.2018.09.06.06.30.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 06:30:36 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w86DUK4t128776
	for <linux-mm@kvack.org>; Thu, 6 Sep 2018 09:30:35 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mb2a5833c-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Sep 2018 09:30:34 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 6 Sep 2018 14:30:31 +0100
Date: Thu, 6 Sep 2018 16:30:23 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 00/29] mm: remove bootmem allocator
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
 <CAEbi=3dKL1zOYc0DC3yXm=7srw6tUfx-JR=o9n4pVrGp+Sosug@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAEbi=3dKL1zOYc0DC3yXm=7srw6tUfx-JR=o9n4pVrGp+Sosug@mail.gmail.com>
Message-Id: <20180906133023.GL27492@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greentime Hu <green.hu@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, gregkh@linuxfoundation.org, mingo@redhat.com, mpe@ellerman.id.au, mhocko@suse.com, paul.burton@mips.com, Thomas Gleixner <tglx@linutronix.de>, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux <sparclinux@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Sep 06, 2018 at 10:33:48AM +0800, Greentime Hu wrote:
> Mike Rapoport <rppt@linux.vnet.ibm.com> ae? 1/4  2018a1'9ae??6ae?JPY e?+-a?? a,?a??12:04a?<<e??i 1/4 ?
> >
> > Hi,
> >
> > These patches switch early memory managment to use memblock directly
> > without any bootmem compatibility wrappers. As the result both bootmem and
> > nobootmem are removed.
> >
> > There are still a couple of things to sort out, the most important is the
> > removal of bootmem usage in MIPS.
> >
> > Still, IMHO, the series is in sufficient state to post and get the early
> > feedback.
> >
> > The patches are build-tested with defconfig for most architectures (I
> > couldn't find a compiler for nds32 and unicore32) and boot-tested on x86
> > VM.
> >
> Hi Mike,
> 
> There are nds32 toolchains.
> https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/8.1.0/x86_64-gcc-8.1.0-nolibc-nds32le-linux.tar.gz
> https://github.com/vincentzwc/prebuilt-nds32-toolchain/releases/download/20180521/nds32le-linux-glibc-v3-upstream.tar.gz

Thanks!
 
> Sorry, we have no qemu yet.
> 

-- 
Sincerely yours,
Mike.
