Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id D37718E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 17:34:14 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id l131so12115822ywc.21
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 14:34:14 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id t20si10695947ywf.315.2018.12.18.14.34.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 14:34:13 -0800 (PST)
Subject: Re: [PATCH 2/3] hugetlbfs: Use i_mmap_rwsem to fix page
 fault/truncate race
References: <20181203200850.6460-1-mike.kravetz@oracle.com>
 <20181203200850.6460-3-mike.kravetz@oracle.com>
 <27f8893b-57b3-088d-2d48-9e8acc5987bd@linux.ibm.com>
 <f6fd9491-4b3d-16ca-f606-025c78756936@oracle.com>
 <dbc4abb9-aa7b-6515-0f37-23a77b50ff6e@oracle.com>
 <20181218141053.e2725111ce5cc91493efab5f@linux-foundation.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <dd36ee7e-939f-f324-6ab6-3d0178617c63@oracle.com>
Date: Tue, 18 Dec 2018 14:34:01 -0800
MIME-Version: 1.0
In-Reply-To: <20181218141053.e2725111ce5cc91493efab5f@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Prakash Sangappa <prakash.sangappa@oracle.com>, stable@vger.kernel.org

On 12/18/18 2:10 PM, Andrew Morton wrote:
> On Mon, 17 Dec 2018 16:17:52 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:
> 
>> ...
>>
>>> As you suggested in a comment to the subsequent patch, it would be better to
>>> combine the patches and remove the dead code when it becomes dead.  I will
>>> work on that.  Actually some of the code in patch 3 applies to patch 1 and
>>> some applies to patch 2.  So, it will not be simply combining patch 2 and 3.
>>
>> On second thought, the cleanups in patch 3 only apply to patch 2.  So, just
>> combining those two patches with a slightly updated commit message as below
>> makes the most sense.
> 
> All confused.  I dropped the current version, let's try again.
> 
> This:
> 
>> Hoping to get more comments on the overall direction and locking changes
>> of this and the previous patch.
> 
> and this:
> 
>> Cc: <stable@vger.kernel.org>
>> Fixes: ebed4bfc8da8 ("hugetlb: fix absurd HugePages_Rsvd")
> 
> make for a hot combination.  Could people please prioritize review of
> this code?
> 
> Perhaps a refresh and resend is in order.

Will send out a new version shortly.  No functional changes.  Only changes
to the way the patches are structured.

I guess fixing in stable could be open for discussion.  These issues have
been around for more than 10 years.  I am not aware of anyone hitting them
in actual real world usage.  The problems were only "found" through code
inspection while working other issues in the same code.  However, after
discovering the issues it was pretty easy to write user space code to
expose them.

-- 
Mike Kravetz
