Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9F07E6B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 13:07:40 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id o52so16472317qtc.10
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 10:07:40 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id t29si8874881qkt.434.2017.10.10.10.07.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 10:07:39 -0700 (PDT)
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v9AH7bbs003853
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 17:07:38 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id v9AH7bKH015771
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 17:07:37 GMT
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id v9AH7aGW007823
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 17:07:37 GMT
Received: by mail-oi0-f51.google.com with SMTP id v132so26944640oie.1
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 10:07:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171010155619.GA2517@arm.com>
References: <20171009221931.1481-1-pasha.tatashin@oracle.com>
 <20171009221931.1481-8-pasha.tatashin@oracle.com> <20171010155619.GA2517@arm.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Tue, 10 Oct 2017 13:07:35 -0400
Message-ID: <CAOAebxv21+KtXPAk-xWz=+2fqWQDgp9SAFZz-N=XsuBxev=zcg@mail.gmail.com>
Subject: Re: [PATCH v11 7/9] arm64/kasan: add and use kasan_map_populate()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, Michal Hocko <mhocko@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Mark Rutland <mark.rutland@arm.com>, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, Steve Sistare <steven.sistare@oracle.com>, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Hi Will,

Thank you for doing this work. How would you like to proceed?

- If you OK for my series to be accepted as-is, so your patch can be
added later on top, I think, I need an ack from you for kasan changes.
- Otherwise, I can replace: 4267aaf1d279 arm64/kasan: add and use
kasan_map_populate() in my series with code from your patch.

Thank you,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
