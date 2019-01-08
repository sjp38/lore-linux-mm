Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id D395D8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 02:15:19 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id 143so1554965pgc.3
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 23:15:19 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v141si68372260pfc.260.2019.01.07.23.15.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 23:15:18 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x087DRk7062090
	for <linux-mm@kvack.org>; Tue, 8 Jan 2019 02:15:18 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pvndbnmur-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 Jan 2019 02:15:17 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 8 Jan 2019 07:15:15 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: Re: [Bug 202149] New: NULL Pointer Dereference in __split_huge_pmd on PPC64LE
In-Reply-To: <20190104170459.c8c7fa57ba9bc8a69dee5666@linux-foundation.org>
References: <bug-202149-27@https.bugzilla.kernel.org/> <20190104170459.c8c7fa57ba9bc8a69dee5666@linux-foundation.org>
Date: Tue, 08 Jan 2019 12:45:08 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87ef9nk4cj.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org
Cc: bugzilla-daemon@bugzilla.kernel.org, kernel@bluematt.me

Andrew Morton <akpm@linux-foundation.org> writes:

> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
>
> On Fri, 04 Jan 2019 22:49:52 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
>
>> https://bugzilla.kernel.org/show_bug.cgi?id=202149
>> 
>>             Bug ID: 202149
>>            Summary: NULL Pointer Dereference in __split_huge_pmd on
>>                     PPC64LE
>
> I think that trace is pointing at the ppc-specific
> pgtable_trans_huge_withdraw()?
>

That is correct. 

Matt,
Can you share the .config used for the kernel. Does this happen only
with 4K page size ?

-aneesh
