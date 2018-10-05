Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5E8256B000D
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 11:05:56 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id h21-v6so7656471oib.16
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 08:05:56 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c7-v6si3908161otb.312.2018.10.05.08.05.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Oct 2018 08:05:55 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w95F4sRc076677
	for <linux-mm@kvack.org>; Fri, 5 Oct 2018 11:05:54 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mx8da6pcj-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 05 Oct 2018 11:05:54 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 5 Oct 2018 16:05:51 +0100
Date: Fri, 05 Oct 2018 18:05:01 +0300
In-Reply-To: <8891277c7de92e93d3bfc409df95810ee6f103cd.camel@kernel.crashing.org>
References: <1538687224-17535-1-git-send-email-rppt@linux.vnet.ibm.com> <8891277c7de92e93d3bfc409df95810ee6f103cd.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH] memblock: stop using implicit alignement to SMP_CACHE_BYTES
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Message-Id: <59C9470E-F718-4A11-BC65-FD68901723AC@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org
Cc: linux-mips@linux-mips.org, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Richard Weinberger <richard@nod.at>, Russell King <linux@armlinux.org.uk>, Ingo Molnar <mingo@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Matt Turner <mattst88@gmail.com>, linux-um@lists.infradead.org, linux-m68k@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Chris Zankel <chris@zankel.net>, Michal Simek <monstr@monstr.eu>, Tony Luck <tony.luck@intel.com>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, linux-alpha@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org



On October 5, 2018 6:25:38 AM GMT+03:00, Benjamin Herrenschmidt <benh@kern=
el=2Ecrashing=2Eorg> wrote:
>On Fri, 2018-10-05 at 00:07 +0300, Mike Rapoport wrote:
>> When a memblock allocation APIs are called with align =3D 0, the
>alignment is
>> implicitly set to SMP_CACHE_BYTES=2E
>>=20
>> Replace all such uses of memblock APIs with the 'align' parameter
>explicitly
>> set to SMP_CACHE_BYTES and stop implicit alignment assignment in the
>> memblock internal allocation functions=2E
>>=20
>> For the case when memblock APIs are used via helper functions, e=2Eg=2E
>like
>> iommu_arena_new_node() in Alpha, the helper functions were detected
>with
>> Coccinelle's help and then manually examined and updated where
>appropriate=2E
>>=20
>> The direct memblock APIs users were updated using the semantic patch
>below:
>
>What is the purpose of this ? It sounds rather counter-intuitive=2E=2E=2E

Why?
I think it actually more intuitive to explicitly set alignment to SMP_CACH=
E_BYTES rather than use align =3D 0 because deeply inside allocator it will=
 be implicitly reset to SMP_CACHE_BYTES=2E=2E=2E

>Ben=2E

--=20
Sincerely yours,
Mike=2E
