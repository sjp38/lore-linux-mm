Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DFE586B0069
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 06:00:51 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id w128so187987842pfd.3
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 03:00:51 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s9si22050488pfi.100.2016.08.22.03.00.50
        for <linux-mm@kvack.org>;
        Mon, 22 Aug 2016 03:00:50 -0700 (PDT)
Date: Mon, 22 Aug 2016 11:00:45 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC PATCH v2 2/2] arm64 Kconfig: Select gigantic page
Message-ID: <20160822100045.GA26494@e104818-lin.cambridge.arm.com>
References: <1471834603-27053-1-git-send-email-xieyisheng1@huawei.com>
 <1471834603-27053-3-git-send-email-xieyisheng1@huawei.com>
 <20160822080358.GF13596@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160822080358.GF13596@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Xie Yisheng <xieyisheng1@huawei.com>, mark.rutland@arm.com, linux-mm@kvack.org, sudeep.holla@arm.com, will.deacon@arm.com, linux-kernel@vger.kernel.org, dave.hansen@intel.com, robh+dt@kernel.org, guohanjun@huawei.com, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, linux-arm-kernel@lists.infradead.org, mike.kravetz@oracle.com

On Mon, Aug 22, 2016 at 10:03:58AM +0200, Michal Hocko wrote:
> On Mon 22-08-16 10:56:43, Xie Yisheng wrote:
> > Arm64 supports gigantic page after
> > commit 084bd29810a5 ("ARM64: mm: HugeTLB support.")
> > however, it got broken by 
> > commit 944d9fec8d7a ("hugetlb: add support for gigantic page
> > allocation at runtime")
> > 
> > This patch selects ARCH_HAS_GIGANTIC_PAGE to make this
> > function can be used again.
> 
> I haven't double checked that the above commit really broke it but if
> that is the case then
>  
> Fixes: 944d9fec8d7a ("hugetlb: add support for gigantic page allocation at runtime")
> 
> would be nice as well I guess. I do not think that marking it for stable
> is really necessary considering how long it's been broken and nobody has
> noticed...

I'm not sure that commit broke it. The gigantic functionality introduced
by the above commit was under an #ifdef CONFIG_X86_64. Prior
to that we had a VM_BUG_ON(hstate_is_gigantic(h)).

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
