Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 29B9B6B02B4
	for <linux-mm@kvack.org>; Tue, 23 May 2017 07:20:56 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id m5so160991390pfc.1
        for <linux-mm@kvack.org>; Tue, 23 May 2017 04:20:56 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n71si20706735pfg.266.2017.05.23.04.20.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 04:20:55 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4NBIrn5002233
	for <linux-mm@kvack.org>; Tue, 23 May 2017 07:20:55 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2am9aesnfk-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 May 2017 07:20:54 -0400
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 23 May 2017 21:20:51 +1000
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v4NBKdwM55312444
	for <linux-mm@kvack.org>; Tue, 23 May 2017 21:20:47 +1000
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v4NBKFYF019484
	for <linux-mm@kvack.org>; Tue, 23 May 2017 21:20:15 +1000
Subject: Re: [PATCH] mm: Define KB, MB, GB, TB in core VM
References: <20170522111742.29433-1-khandual@linux.vnet.ibm.com>
 <20170522141149.9ef84bb0713769f4af0383f0@linux-foundation.org>
 <20170523070227.GA27864@infradead.org>
 <09a6bafa-5743-425e-8def-bd9219cd756c@suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 23 May 2017 16:49:57 +0530
MIME-Version: 1.0
In-Reply-To: <09a6bafa-5743-425e-8def-bd9219cd756c@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <161638da-3b2b-7912-2ae2-3b2936ca1537@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/23/2017 02:08 PM, Vlastimil Babka wrote:
> On 05/23/2017 09:02 AM, Christoph Hellwig wrote:
>> On Mon, May 22, 2017 at 02:11:49PM -0700, Andrew Morton wrote:
>>> On Mon, 22 May 2017 16:47:42 +0530 Anshuman Khandual <khandual@linux.vnet.ibm.com> wrote:
>>>
>>>> There are many places where we define size either left shifting integers
>>>> or multiplying 1024s without any generic definition to fall back on. But
>>>> there are couples of (powerpc and lz4) attempts to define these standard
>>>> memory sizes. Lets move these definitions to core VM to make sure that
>>>> all new usage come from these definitions eventually standardizing it
>>>> across all places.
>>> Grep further - there are many more definitions and some may now
>>> generate warnings.
>>>
>>> Newly including mm.h for these things seems a bit heavyweight.  I can't
>>> immediately think of a more appropriate place.  Maybe printk.h or
>>> kernel.h.
>> IFF we do these kernel.h is the right place.  And please also add the
>> MiB & co variants for the binary versions right next to the decimal
>> ones.
> Those defined in the patch are binary, not decimal. Do we even need
> decimal ones?
> 

I can define KiB, MiB, .... with the same values as binary.
Did not get about the decimal ones, we need different names
for them holding values which are multiple of 1024 ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
