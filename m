Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 11E886B007E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 12:02:50 -0400 (EDT)
Received: by mail-ob0-f179.google.com with SMTP id fp4so16976087obb.2
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 09:02:50 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id e52si1760082otc.84.2016.03.23.09.02.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Mar 2016 09:02:49 -0700 (PDT)
Subject: Re: [PATCH v2 0/6] mm/hugetlb: Fix commandline parsing behavior for
 invalid hugepagesize
References: <1458734844-14833-1-git-send-email-vaishali.thakkar@oracle.com>
 <20160323133011.GG7059@dhcp22.suse.cz>
From: Vaishali Thakkar <vaishali.thakkar@oracle.com>
Message-ID: <56F2BDE3.40309@oracle.com>
Date: Wed, 23 Mar 2016 21:31:39 +0530
MIME-Version: 1.0
In-Reply-To: <20160323133011.GG7059@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@oracle.com, hillf.zj@alibaba-inc.com, baiyaowei@cmss.chinamobile.com, dingel@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, paul.gortmaker@windriver.com, catalin.marinas@arm.com, will.deacon@arm.com, cmetcalf@ezchip.com, linux-arm-kernel@lists.infradead.org, james.hogan@imgtec.com, linux-metag@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org



On Wednesday 23 March 2016 07:00 PM, Michal Hocko wrote:
> On Wed 23-03-16 17:37:18, Vaishali Thakkar wrote:
>> Current code fails to ignore the 'hugepages=' parameters when unsupported
>> hugepagesize is specified. With this patchset, introduce new architecture
>> independent routine hugetlb_bad_size to handle such command line options.
>> And then call it in architecture specific code.
>>
>> Changes since v1:
>> 	- Separated different architecture specific changes in different
>> 	  patches
>> 	- CC'ed all arch maintainers
> The hugetlb parameters parsing is a bit mess but this at least makes it
> behave more consistently. Feel free to add to all patches
> Acked-by: Michal Hocko <mhocko@suse.com>
>
> On a side note. I have received patches with broken threading - the
> follow up patches are not in the single thread under this cover email.
> I thought this was the default behavior of git send-email but maybe your
> (older) version doesn't do that. --thread option would enforce that
> (with --no-chain-reply-to) or you can set it up in the git config. IMHO
> it is always better to have the patchset in the single email thread.
>
Yes, now I have set up my git config for that. Hopefully, things will
work properly - patchset in a single thread from the next time.

Thanks.

-- 
Vaishali

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
