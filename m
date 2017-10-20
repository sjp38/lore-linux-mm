Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id E276E6B0038
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 21:13:24 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id s26so9417489qts.19
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 18:13:24 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id t126si3998902qkc.289.2017.10.19.18.13.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 18:13:23 -0700 (PDT)
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v9K1DM6V011990
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 01:13:22 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id v9K1DKOW013464
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 01:13:20 GMT
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id v9K1DJ85021278
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 01:13:20 GMT
Received: by mail-oi0-f47.google.com with SMTP id w197so17841823oif.6
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 18:13:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171019165921.de4224c8e627b1477cfb50de@linux-foundation.org>
References: <20171013173214.27300-1-pasha.tatashin@oracle.com>
 <20171013173214.27300-10-pasha.tatashin@oracle.com> <20171019165921.de4224c8e627b1477cfb50de@linux-foundation.org>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Thu, 19 Oct 2017 21:13:18 -0400
Message-ID: <CAOAebxswpsLEtvZXwj0Qk62=5KC6Xh2ewaHrWJVbo_O=9Hye9Q@mail.gmail.com>
Subject: Re: [PATCH v12 09/11] mm: stop zeroing memory during allocation in vmemmap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, Michal Hocko <mhocko@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Mark Rutland <mark.rutland@arm.com>, Will Deacon <will.deacon@arm.com>, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, Steve Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Bob Picco <bob.picco@oracle.com>

This looks good to me, thank you Andrew.

Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
