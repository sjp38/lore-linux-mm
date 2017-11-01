Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 341876B0038
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 17:35:36 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 76so3250891pfr.3
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 14:35:36 -0700 (PDT)
Received: from osg.samsung.com (osg.samsung.com. [64.30.133.232])
        by mx.google.com with ESMTP id n10si521977plk.413.2017.11.01.14.35.34
        for <linux-mm@kvack.org>;
        Wed, 01 Nov 2017 14:35:35 -0700 (PDT)
Subject: Re: [PATCH] selftests/vm: Add tests validating mremap mirror
 functionality
References: <20171030031808.24934-1-khandual@linux.vnet.ibm.com>
From: Shuah Khan <shuahkh@osg.samsung.com>
Message-ID: <0facab37-cdb3-1670-abc3-f4fdcc2e4e19@osg.samsung.com>
Date: Wed, 1 Nov 2017 15:35:32 -0600
MIME-Version: 1.0
In-Reply-To: <20171030031808.24934-1-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: mike.kravetz@oracle.com, mhocko@kernel.org, Shuah Khan <shuahkh@osg.samsung.com>, Shuah Khan <shuah@kernel.org>

On 10/29/2017 09:18 PM, Anshuman Khandual wrote:
> This adds two tests to validate mirror functionality with mremap()
> system call on shared and private anon mappings. After the commit
> dba58d3b8c5 ("mm/mremap: fail map duplication attempts for private
> mappings"), any attempt to mirror private anon mapping will fail.
> 
> Suggested-by: Mike Kravetz <mike.kravetz@oracle.com>
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
> Changes in V4:
> 
> - Folded these two test files into just one as per Mike
> - Did some renaming of functions, cleans ups etc
> 
> Changes in V3: (https://patchwork.kernel.org/patch/10013469/)
> 
> - Fail any attempts to mirror an existing anon private mapping
> - Updated run_vmtests to include these new mremap tests
> - Updated the commit message
> 
> Changes in V2: (https://patchwork.kernel.org/patch/9861259/)
> 
> - Added a test for private anon mappings
> - Used sysconf(_SC_PAGESIZE) instead of hard coding page size
> - Used MREMAP_MAYMOVE instead of hard coding the flag value 1
> 
> Original V1: (https://patchwork.kernel.org/patch/9854415/)

Thanks. I will queue this up for 4.15-rc1

-- Shuah

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
