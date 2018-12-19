Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2DFFF8E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 22:18:23 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id y35so14854912edb.5
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 19:18:23 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b13si163501edq.217.2018.12.18.19.18.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 19:18:22 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBJ396BU010982
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 22:18:20 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pfb9np02v-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 22:18:20 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 19 Dec 2018 03:18:18 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: Re: [PATCH V4 0/5] NestMMU pte upgrade workaround for mprotect
In-Reply-To: <20181218171703.GA22729@infradead.org>
References: <20181218094137.13732-1-aneesh.kumar@linux.ibm.com> <20181218171703.GA22729@infradead.org>
Date: Wed, 19 Dec 2018 08:48:02 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87tvjafbmd.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Christoph Hellwig <hch@infradead.org> writes:

> This series seems to miss patches 1 and 2.

https://lore.kernel.org/linuxppc-dev/20181218094137.13732-2-aneesh.kumar@linux.ibm.com/
https://lore.kernel.org/linuxppc-dev/20181218094137.13732-3-aneesh.kumar@linux.ibm.com/

-aneesh
