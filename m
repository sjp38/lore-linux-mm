Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 302EF6B0265
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 06:34:55 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v67so94047650pfv.1
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 03:34:55 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id ln2si40236485pab.23.2016.09.21.03.34.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 03:34:54 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8LAX1jk034644
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 06:34:54 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25kkb5w3e5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 06:34:53 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Wed, 21 Sep 2016 11:34:51 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 242EB1B0804B
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 11:36:41 +0100 (BST)
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8LAYnNl43384918
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 10:34:49 GMT
Received: from d06av02.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8LAYmEv005984
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 04:34:49 -0600
Date: Wed, 21 Sep 2016 12:34:47 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH 0/1] memory offline issues with hugepage size > memory
 block size
In-Reply-To: <57E175B3.1040802@linux.intel.com>
References: <20160920155354.54403-1-gerald.schaefer@de.ibm.com>
	<bc000c05-3186-da92-e868-f2dbf0c28a98@oracle.com>
	<57E175B3.1040802@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20160921123447.2c3ff33c@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>

On Tue, 20 Sep 2016 10:45:23 -0700
Dave Hansen <dave.hansen@linux.intel.com> wrote:

> On 09/20/2016 10:37 AM, Mike Kravetz wrote:
> > 
> > Their approach (I believe) would be to fail the offline operation in
> > this case.  However, I could argue that failing the operation, or
> > dissolving the unused huge page containing the area to be offlined is
> > the right thing to do.
> 
> I think the right thing to do is dissolve the whole huge page if even a
> part of it is offlined.  The only question is what to do with the
> gigantic remnants.
> 

Hmm, not sure if I got this right, but I thought that by calling
update_and_free_page() on the head page (even if it is not part of the
memory block to be removed) all parts of the gigantic hugepage should be
properly freed and there should not be any remnants left.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
