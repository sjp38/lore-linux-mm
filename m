Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 723DE6B0038
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 07:05:51 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id y68so68411587pfb.6
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 04:05:51 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f67si36585754pgc.288.2016.11.08.04.05.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Nov 2016 04:05:50 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA8C3vTc092848
	for <linux-mm@kvack.org>; Tue, 8 Nov 2016 07:05:49 -0500
Received: from e06smtp09.uk.ibm.com (e06smtp09.uk.ibm.com [195.75.94.105])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26kd9m5nqr-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 Nov 2016 07:05:49 -0500
Received: from localhost
	by e06smtp09.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Tue, 8 Nov 2016 12:05:47 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 2281A1B0806E
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 12:07:57 +0000 (GMT)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uA8C5imH30802076
	for <linux-mm@kvack.org>; Tue, 8 Nov 2016 12:05:44 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uA8C5ifm031644
	for <linux-mm@kvack.org>; Tue, 8 Nov 2016 05:05:44 -0700
Date: Tue, 8 Nov 2016 13:05:42 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH] mm: only enable sys_pkey* when ARCH_HAS_PKEYS
References: <1477958904-9903-1-git-send-email-mark.rutland@arm.com>
 <20161104234459.GA18760@remoulade>
 <20161108093042.GC3528@osiris>
 <1596342.1rV5HksyDO@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1596342.1rV5HksyDO@wuerfel>
Message-Id: <20161108120542.GG3528@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Mark Rutland <mark.rutland@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Russell King <rmk+kernel@armlinux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org

On Tue, Nov 08, 2016 at 12:39:28PM +0100, Arnd Bergmann wrote:
> On Tuesday, November 8, 2016 10:30:42 AM CET Heiko Carstens wrote:
> > Three architectures (parisc, powerpc, s390) decided to ignore the system
> > calls completely, but still have the pkey code linked into the kernel
> > image.
> 
> Wouldn't it actually make sense to hook this up to the storage keys
> in the s390 page tables?

We have storage keys per _physical_ page. Not per page within the the table
entries. So this doesn't work unfortunately.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
