Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 70C2D6B02C3
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 17:18:46 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id s18so27956528qks.4
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 14:18:46 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id q27si4295769qtq.519.2017.07.21.14.18.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jul 2017 14:18:45 -0700 (PDT)
Subject: Re: [PATCH v2] mm/mremap: Fail map duplication attempts for private
 mappings
References: <20170720082058.GF9058@dhcp22.suse.cz>
 <1500583079-26504-1-git-send-email-mike.kravetz@oracle.com>
 <20170721143644.GC5944@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <cb9d9f6a-7095-582f-15a5-62643d65c736@oracle.com>
Date: Fri, 21 Jul 2017 14:18:31 -0700
MIME-Version: 1.0
In-Reply-To: <20170721143644.GC5944@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Linux API <linux-api@vger.kernel.org>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

On 07/21/2017 07:36 AM, Michal Hocko wrote:
> On Thu 20-07-17 13:37:59, Mike Kravetz wrote:
>> mremap will create a 'duplicate' mapping if old_size == 0 is
>> specified.  Such duplicate mappings make no sense for private
>> mappings.
> 
> sorry for the nit picking but this is not true strictly speaking.
> It makes some sense, arguably (e.g. take an atomic snapshot of the
> mapping). It doesn't make any sense with the _current_ implementation.
> 
>> If duplication is attempted for a private mapping,
>> mremap creates a separate private mapping unrelated to the
>> original mapping and makes no modifications to the original.
>> This is contrary to the purpose of mremap which should return
>> a mapping which is in some way related to the original.
>>
>> Therefore, return EINVAL in the case where if an attempt is
>> made to duplicate a private mapping.  Also, print a warning
>> message (once) if such an attempt is made.
>>
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> 
> I do not insist on the comment update suggested
> http://lkml.kernel.org/r/20170720082058.GF9058@dhcp22.suse.cz
> but I would appreciate it...
> 
> Other than that looks reasonably to me
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

My apologies.  I overlooked your comment about the comment when
creating the patch.  Below is the patch with commit message and
comment updated.
