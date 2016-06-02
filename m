Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 484DA6B025E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 15:11:11 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fg1so61610461pad.1
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 12:11:11 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m7si247984pab.125.2016.06.02.12.11.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 12:11:10 -0700 (PDT)
Received: from pps.filterd (m0075420.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u52JB7hj009167
	for <linux-mm@kvack.org>; Thu, 2 Jun 2016 15:11:09 -0400
Message-Id: <201606021911.u52JB7hj009167@mx0a-001b2d01.pphosted.com>
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23ang61crq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 02 Jun 2016 15:11:09 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Thu, 2 Jun 2016 20:11:00 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id E966B17D8042
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 20:12:05 +0100 (BST)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u52JAwXc24707386
	for <linux-mm@kvack.org>; Thu, 2 Jun 2016 19:10:58 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u52JAv5D020282
	for <linux-mm@kvack.org>; Thu, 2 Jun 2016 15:10:58 -0400
Subject: Re: [BUG/REGRESSION] THP: broken page count after commit aa88b68c
References: <20160602172141.75c006a9@thinkpad>
 <20160602155149.GB8493@node.shutemov.name>
 <20160602114031.64b178c823901c171ec82745@linux-foundation.org>
 <201606021856.u52ImC6o037023@mx0a-001b2d01.pphosted.com>
 <20160602120335.4b38dd2bee7b3740ab025f79@linux-foundation.org>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Thu, 2 Jun 2016 21:10:56 +0200
MIME-Version: 1.0
In-Reply-To: <20160602120335.4b38dd2bee7b3740ab025f79@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On 06/02/2016 09:03 PM, Andrew Morton wrote:
> On Thu, 2 Jun 2016 20:56:27 +0200 Christian Borntraeger <borntraeger@de.ibm.com> wrote:
> 
>>>> The fix looks good to me.
>>>
>>> Yes.  A bit regrettable, but that's what release_pages() does.
>>>
>>> Can we have a signed-off-by please?
>>
>> Please also add CC: stable for 4.6
> 
> I shall take that as a "yes" and I'll add
> 
> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
> 
> to the changelog.

Gerald has created the patch,
but you could add 
Reported-by: Christian Borntraeger <borntraeger@de.ibm.com>
Tested-by: Christian Borntraeger <borntraeger@de.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
