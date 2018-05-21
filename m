Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1579E6B0003
	for <linux-mm@kvack.org>; Sun, 20 May 2018 22:34:30 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id d9-v6so9233881plj.4
        for <linux-mm@kvack.org>; Sun, 20 May 2018 19:34:30 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id s24-v6si12422944pfm.257.2018.05.20.19.34.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 May 2018 19:34:28 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm] mm, huge page: Copy to access sub-page last when copy huge page
References: <20180518030316.31019-1-ying.huang@intel.com>
	<20180518062430.GB21711@dhcp22.suse.cz>
	<64430ed4-4019-d597-ccb3-8bf6b04ee464@oracle.com>
Date: Mon, 21 May 2018 10:34:25 +0800
In-Reply-To: <64430ed4-4019-d597-ccb3-8bf6b04ee464@oracle.com> (Mike Kravetz's
	message of "Fri, 18 May 2018 09:41:04 -0700")
Message-ID: <87bmd9ka8e.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <andi.kleen@intel.com>, Jan Kara <jack@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>, Christopher Lameter <cl@linux.com>

Mike Kravetz <mike.kravetz@oracle.com> writes:

> On 05/17/2018 11:24 PM, Michal Hocko wrote:
>> On Fri 18-05-18 11:03:16, Huang, Ying wrote:
>> [...]
>>> The patch is a generic optimization which should benefit quite some
>>> workloads, not for a specific use case.  To demonstrate the performance
>>> benefit of the patch, we tested it with vm-scalability run on
>>> transparent huge page.
>> 
>> It is also adds quite some non-intuitive code. So is this worth? Does
>> any _real_ workload benefits from the change?
>
> One way to 'add less code' would be to create a helper routine that
> indicates the order in which sub-pages are to be copied.  IIUC, you
> added the same algorithm for sub-page ordering to copy_huge_page()
> that was previously added to clear_huge_page().  Correct?

Yes.

> If so, then perhaps a common helper could be used by both the clear
> and copy huge page routines.  It would also make maintenance easier.

That's a good idea.  But this may need to turn
copy_user_highpage()/clear_user_highpage() calling in
copy_user_huge_page()/clear_huge_page() from direct call to indirect
call.  I don't know whether this will incur some overhead.  Will try to
measure this.

Best Regards,
Huang, Ying
