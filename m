Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id BF7F86B025F
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 15:07:06 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id g18so20207727itg.1
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 12:07:06 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id f30si7071361ioi.176.2017.10.09.12.07.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 12:07:06 -0700 (PDT)
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v99J74B1024224
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 9 Oct 2017 19:07:04 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id v99J73Qa027112
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 9 Oct 2017 19:07:03 GMT
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id v99J73Ma006648
	for <linux-mm@kvack.org>; Mon, 9 Oct 2017 19:07:03 GMT
Received: by mail-oi0-f49.google.com with SMTP id c77so39413693oig.0
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 12:07:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171009190213.GF30828@arm.com>
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-10-pasha.tatashin@oracle.com> <20171003144845.GD4931@leverpostej>
 <20171009171337.GE30085@arm.com> <CAOAebxtHHFvYn4WysMASe1GqvgKYPVyjJ572UM3Sef5sP0hi9A@mail.gmail.com>
 <20171009182217.GC30828@arm.com> <CAOAebxu1310eCrk88EC=Oaw3n90-9RuHZ1KBhPvLu_DyXBNZFQ@mail.gmail.com>
 <20171009184834.GE30828@arm.com> <CAOAebxs5s3DKV8f+Zw+LFVB98PE6cs=RwcOH8qEiU_MPLM9RvQ@mail.gmail.com>
 <20171009190213.GF30828@arm.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Mon, 9 Oct 2017 15:07:01 -0400
Message-ID: <CAOAebxvcg9r00bCWDJS4V_mmKk_dELVs_SfxqrxemDg7=uZx_g@mail.gmail.com>
Subject: Re: [PATCH v9 09/12] mm/kasan: kasan specific map populate function
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, catalin.marinas@arm.com, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, sam@ravnborg.org, mgorman@techsingularity.net, Steve Sistare <steven.sistare@oracle.com>, daniel.m.jordan@oracle.com, bob.picco@oracle.com

>
> Ok, but I'm still missing why you think that is needed. What would be the
> second page table walker that needs implementing?
>
> I guess we could implement that on arm64 using our current vmemmap_populate
> logic and an explicit memset.
>

Hi Will,

What do you mean by explicit memset()? We can't simply memset() from
start to end without doing the page table walk, because at the time
kasan is calling vmemmap_populate() we have a tmp_pg_dir instead of
swapper_pg_dir.

We could do the explicit memset() after
cpu_replace_ttbr1(lm_alias(swapper_pg_dir)); but again, this was in
one of my previous implementations, and I was asked to replace that.

Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
