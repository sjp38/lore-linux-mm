Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2FA9E6B212D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 19:06:16 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id z44-v6so74989qtg.5
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 16:06:16 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id v31-v6si23549qtd.403.2018.08.21.16.06.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 16:06:15 -0700 (PDT)
Subject: Re: [PATCH v3 1/2] mm: migration: fix migration of huge PMD shared
 pages
References: <20180821205902.21223-2-mike.kravetz@oracle.com>
 <201808220558.yMC1bC0F%fengguang.wu@intel.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <398fe045-f0cd-d00e-e4cc-2b12cc266ea2@oracle.com>
Date: Tue, 21 Aug 2018 16:06:03 -0700
MIME-Version: 1.0
In-Reply-To: <201808220558.yMC1bC0F%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On 08/21/2018 03:03 PM, kbuild test robot wrote:
> Hi Mike,
> 
> I love your patch! Yet something to improve:
> 
> [auto build test ERROR on linus/master]
> [also build test ERROR on v4.18 next-20180821]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Mike-Kravetz/huge_pmd_unshare-migration-and-flushing/20180822-050255
> config: i386-tinyconfig (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386 

Oops, simple build fix addressed in updated patch below.
