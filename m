Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2F6696B0033
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 11:54:27 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id c36so15413476qtc.12
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 08:54:27 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id x35si1024949qte.401.2017.10.13.08.54.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Oct 2017 08:54:26 -0700 (PDT)
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v9DFsObM030092
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 15:54:25 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id v9DFsNfx022462
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 15:54:24 GMT
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id v9DFsN8P023836
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 15:54:23 GMT
Received: by mail-oi0-f46.google.com with SMTP id v9so14964133oif.13
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 08:54:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171013154426.GC4746@arm.com>
References: <20171009221931.1481-1-pasha.tatashin@oracle.com>
 <20171009221931.1481-8-pasha.tatashin@oracle.com> <20171010155619.GA2517@arm.com>
 <CAOAebxv21+KtXPAk-xWz=+2fqWQDgp9SAFZz-N=XsuBxev=zcg@mail.gmail.com>
 <20171010171047.GC2517@arm.com> <CAOAebxtrSthSP4NAa0obBbsCK1KZxO+x0w5xNrpY6m2y9UZFvQ@mail.gmail.com>
 <CAOAebxu5WL-FQLgfCxNcWy36V6zsTO1v3LLqXv5rM1Pp9R-=YA@mail.gmail.com>
 <20171013144319.GB4746@arm.com> <CAOAebxv4h+8ej6JA_DZbXaNV5JsAk4MbcCLf1+2RvwKGF2+MxQ@mail.gmail.com>
 <20171013154426.GC4746@arm.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 13 Oct 2017 11:54:21 -0400
Message-ID: <CAOAebxspETEqFXL1Ez_4TK9CAwwk+uhHbYOmZk2QR8b=GO80cQ@mail.gmail.com>
Subject: Re: [PATCH v11 7/9] arm64/kasan: add and use kasan_map_populate()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, Michal Hocko <mhocko@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Mark Rutland <mark.rutland@arm.com>, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, Steve Sistare <steven.sistare@oracle.com>, daniel.m.jordan@oracle.com, bob.picco@oracle.com

> Thanks for sharing the .config and tree. It looks like the problem is that
> kimg_shadow_start and kimg_shadow_end are not page-aligned. Whilst I fix
> them up in kasan_map_populate, they remain unaligned when passed to
> kasan_populate_zero_shadow, which confuses the loop termination conditions
> in e.g. zero_pte_populate and the shadow isn't configured properly.

This makes sense. Thank you. I will insert these changes into your
patch, and send out a new series soon after sanity checking it.

Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
