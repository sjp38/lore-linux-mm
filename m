Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5AADD6B05F0
	for <linux-mm@kvack.org>; Fri, 18 May 2018 12:41:19 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id c190-v6so6880414vke.15
        for <linux-mm@kvack.org>; Fri, 18 May 2018 09:41:19 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id z23-v6si2191200uaf.287.2018.05.18.09.41.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 09:41:16 -0700 (PDT)
Subject: Re: [PATCH -mm] mm, huge page: Copy to access sub-page last when copy
 huge page
References: <20180518030316.31019-1-ying.huang@intel.com>
 <20180518062430.GB21711@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <64430ed4-4019-d597-ccb3-8bf6b04ee464@oracle.com>
Date: Fri, 18 May 2018 09:41:04 -0700
MIME-Version: 1.0
In-Reply-To: <20180518062430.GB21711@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <andi.kleen@intel.com>, Jan Kara <jack@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>, Christopher Lameter <cl@linux.com>

On 05/17/2018 11:24 PM, Michal Hocko wrote:
> On Fri 18-05-18 11:03:16, Huang, Ying wrote:
> [...]
>> The patch is a generic optimization which should benefit quite some
>> workloads, not for a specific use case.  To demonstrate the performance
>> benefit of the patch, we tested it with vm-scalability run on
>> transparent huge page.
> 
> It is also adds quite some non-intuitive code. So is this worth? Does
> any _real_ workload benefits from the change?

One way to 'add less code' would be to create a helper routine that
indicates the order in which sub-pages are to be copied.  IIUC, you
added the same algorithm for sub-page ordering to copy_huge_page()
that was previously added to clear_huge_page().  Correct?  If so,
then perhaps a common helper could be used by both the clear and copy
huge page routines.  It would also make maintenance easier.

-- 
Mike Kravetz
