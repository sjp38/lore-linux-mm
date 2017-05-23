Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E5DE96B02B4
	for <linux-mm@kvack.org>; Tue, 23 May 2017 07:14:35 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x184so28962348wmf.14
        for <linux-mm@kvack.org>; Tue, 23 May 2017 04:14:35 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z71si17051180wrb.48.2017.05.23.04.14.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 04:14:34 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4NB4NJ3128352
	for <linux-mm@kvack.org>; Tue, 23 May 2017 07:14:33 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2amg5jjk01-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 May 2017 07:14:33 -0400
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 23 May 2017 21:14:30 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v4NBEKNi42270724
	for <linux-mm@kvack.org>; Tue, 23 May 2017 21:14:28 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v4NBDn9o021014
	for <linux-mm@kvack.org>; Tue, 23 May 2017 21:13:49 +1000
Subject: Re: [PATCH] mm: Define KB, MB, GB, TB in core VM
References: <20170522111742.29433-1-khandual@linux.vnet.ibm.com>
 <20170522141149.9ef84bb0713769f4af0383f0@linux-foundation.org>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 23 May 2017 16:43:38 +0530
MIME-Version: 1.0
In-Reply-To: <20170522141149.9ef84bb0713769f4af0383f0@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <528d791b-dda4-26f2-f604-f27c645b9011@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/23/2017 02:41 AM, Andrew Morton wrote:
> On Mon, 22 May 2017 16:47:42 +0530 Anshuman Khandual <khandual@linux.vnet.ibm.com> wrote:
> 
>> There are many places where we define size either left shifting integers
>> or multiplying 1024s without any generic definition to fall back on. But
>> there are couples of (powerpc and lz4) attempts to define these standard
>> memory sizes. Lets move these definitions to core VM to make sure that
>> all new usage come from these definitions eventually standardizing it
>> across all places.
> Grep further - there are many more definitions and some may now
> generate warnings.

Yeah, warning reports started coming in. Will try to change
all of those to follow the new definitions added.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
