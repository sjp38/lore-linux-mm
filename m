Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id A6E6C6B007E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 09:30:32 -0400 (EDT)
Received: by mail-wm0-f44.google.com with SMTP id l68so234064753wml.0
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 06:30:32 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id l65si3784152wmb.26.2016.03.23.06.30.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Mar 2016 06:30:12 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id r129so4417919wmr.2
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 06:30:12 -0700 (PDT)
Date: Wed, 23 Mar 2016 14:30:11 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/6] mm/hugetlb: Fix commandline parsing behavior for
 invalid hugepagesize
Message-ID: <20160323133011.GG7059@dhcp22.suse.cz>
References: <1458734844-14833-1-git-send-email-vaishali.thakkar@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1458734844-14833-1-git-send-email-vaishali.thakkar@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vaishali Thakkar <vaishali.thakkar@oracle.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@oracle.com, hillf.zj@alibaba-inc.com, baiyaowei@cmss.chinamobile.com, dingel@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, paul.gortmaker@windriver.com, catalin.marinas@arm.com, will.deacon@arm.com, cmetcalf@ezchip.com, linux-arm-kernel@lists.infradead.org, james.hogan@imgtec.com, linux-metag@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org

On Wed 23-03-16 17:37:18, Vaishali Thakkar wrote:
> Current code fails to ignore the 'hugepages=' parameters when unsupported
> hugepagesize is specified. With this patchset, introduce new architecture
> independent routine hugetlb_bad_size to handle such command line options.
> And then call it in architecture specific code.
> 
> Changes since v1:
> 	- Separated different architecture specific changes in different
> 	  patches
> 	- CC'ed all arch maintainers

The hugetlb parameters parsing is a bit mess but this at least makes it
behave more consistently. Feel free to add to all patches
Acked-by: Michal Hocko <mhocko@suse.com>

On a side note. I have received patches with broken threading - the
follow up patches are not in the single thread under this cover email.
I thought this was the default behavior of git send-email but maybe your
(older) version doesn't do that. --thread option would enforce that
(with --no-chain-reply-to) or you can set it up in the git config. IMHO
it is always better to have the patchset in the single email thread.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
