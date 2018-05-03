Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CE9C86B000E
	for <linux-mm@kvack.org>; Thu,  3 May 2018 10:42:59 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n78so15362899pfj.4
        for <linux-mm@kvack.org>; Thu, 03 May 2018 07:42:59 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id s24si2553302pfm.257.2018.05.03.07.42.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 07:42:58 -0700 (PDT)
Subject: Re: BUG: Bad page map in process python2 pte:10000000000
 pmd:17e8be067
References: <20180419054047.xxiljmzaf2u7odc6@wfg-t540p.sh.intel.com>
 <17463682-dc08-358d-8b44-02821352604c@intel.com>
 <CAAuJbeKT1eBxT4Y8FgQBrQcFDU_3R8ad=s_8zsyj+GPiZT7VhQ@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <7d386ba4-85ba-85dd-4f81-4cc984b149dd@intel.com>
Date: Thu, 3 May 2018 07:42:57 -0700
MIME-Version: 1.0
In-Reply-To: <CAAuJbeKT1eBxT4Y8FgQBrQcFDU_3R8ad=s_8zsyj+GPiZT7VhQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huaitong Han <oenhan@gmail.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Huang Ying <ying.huang@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, lkp@01.org

On 05/02/2018 08:20 PM, Huaitong Han wrote:
> 
> kernel: swap_free: Bad swap file entry 1000000000103256
> kernel: BUG: Bad page map in process in:imjournal  pte:8192b1000 pmd:3ff9324067
> kernel: addr:00007f920adc5000 vm_flags:080000d1 anon_vma:
> (null) mapping:ffff883fe5284960 index:3f8
> kernel: vma->vm_ops->fault: shmem_fault+0x0/0x1d0
> kernel: vma->vm_file->f_op->mmap: shmem_mmap+0x0/0x30
> kernel: CPU: 5 PID: 9166 Comm: in:imjournal Tainted: G        W  OE
> K------------   3.10.0-514.16.1.el7.x86_64 #1

This looks like an entirely different signature.  There are lots of bits
set in the bad swap entry instead of a single one.  It's also a vintage
RHEL kernel, not mainline.
