Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 897E6440843
	for <linux-mm@kvack.org>; Sun,  9 Jul 2017 03:23:43 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z45so17200381wrb.13
        for <linux-mm@kvack.org>; Sun, 09 Jul 2017 00:23:43 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p64si1536306wmp.45.2017.07.09.00.23.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jul 2017 00:23:42 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v697IqK2088825
	for <linux-mm@kvack.org>; Sun, 9 Jul 2017 03:23:40 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2bjux32bg9-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 09 Jul 2017 03:23:40 -0400
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Sun, 9 Jul 2017 17:23:37 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v697NZgM20185176
	for <linux-mm@kvack.org>; Sun, 9 Jul 2017 17:23:35 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v697NQcJ007697
	for <linux-mm@kvack.org>; Sun, 9 Jul 2017 17:23:26 +1000
Subject: Re: [RFC PATCH 1/1] mm/mremap: add MREMAP_MIRROR flag for existing
 mirroring functionality
References: <1499357846-7481-1-git-send-email-mike.kravetz@oracle.com>
 <1499357846-7481-2-git-send-email-mike.kravetz@oracle.com>
 <ea962c4b-3d47-2a95-7697-2efb4e8cd2f0@linux.vnet.ibm.com>
 <3a43d5fa-223d-1315-513b-85d3a09a07b6@oracle.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Sun, 9 Jul 2017 12:53:30 +0530
MIME-Version: 1.0
In-Reply-To: <3a43d5fa-223d-1315-513b-85d3a09a07b6@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <37f275bb-57c2-1485-02f2-dc71021f612a@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On 07/07/2017 10:44 PM, Mike Kravetz wrote:
> On 07/07/2017 01:45 AM, Anshuman Khandual wrote:
>> On 07/06/2017 09:47 PM, Mike Kravetz wrote:
>>> The mremap system call has the ability to 'mirror' parts of an existing
>>> mapping.  To do so, it creates a new mapping that maps the same pages as
>>> the original mapping, just at a different virtual address.  This
>>> functionality has existed since at least the 2.6 kernel.
>>>
>>> This patch simply adds a new flag to mremap which will make this
>>> functionality part of the API.  It maintains backward compatibility with
>>> the existing way of requesting mirroring (old_size == 0).
>>>
>>> If this new MREMAP_MIRROR flag is specified, then new_size must equal
>>> old_size.  In addition, the MREMAP_MAYMOVE flag must be specified.
>>
>> Yeah it all looks good. But why is this requirement that if
>> MREMAP_MAYMOVE is specified then old_size and new_size must
>> be equal.
> 
> No real reason.  I just wanted to clearly separate the new interface from
> the old.  On second thought, it would be better to require old_size == 0
> as in the legacy interface.

That would be redundant. Mirroring will just happen because old_size is
0 whether we mention the MREMAP_MIRROR flag or not. IMHO it should just
mirror if the flag is specified irrespective of the old_size value.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
