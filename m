Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5CD4B6B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 10:30:56 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id 7so18985666uak.19
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 07:30:56 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id x31si927079ioe.128.2017.10.10.07.30.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 07:30:55 -0700 (PDT)
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v9AEUspk012145
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 14:30:54 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id v9AEUr56013943
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 14:30:53 GMT
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id v9AEUruw002188
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 14:30:53 GMT
Received: by mail-oi0-f42.google.com with SMTP id j126so45468768oia.10
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 07:30:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171010140942.qe4mlby5uizt56pz@dhcp22.suse.cz>
References: <20171009221931.1481-1-pasha.tatashin@oracle.com>
 <20171009221931.1481-6-pasha.tatashin@oracle.com> <20171010134441.pjemi7ytaqcfm372@dhcp22.suse.cz>
 <20171010140942.qe4mlby5uizt56pz@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Tue, 10 Oct 2017 10:30:52 -0400
Message-ID: <CAOAebxtwYVDT10fGsRhGT25WzC3YVAzAm7X1bqmWnO__Cc1+Kg@mail.gmail.com>
Subject: Re: [PATCH v11 5/9] mm: zero reserved and unavailable struct pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Mark Rutland <mark.rutland@arm.com>, Will Deacon <will.deacon@arm.com>, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, Steve Sistare <steven.sistare@oracle.com>, daniel.m.jordan@oracle.com, bob.picco@oracle.com

> Btw. I would add your example from http://lkml.kernel.org/r/bcf24369-ac37-cedd-a264-3396fb5cf39e@oracle.com
> to do changelog
>

Will add, thank you for your review.

Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
