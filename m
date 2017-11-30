Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 79F896B0253
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 11:19:45 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id 74so3630986otv.10
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 08:19:45 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t9si1422995oig.347.2017.11.30.08.19.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 08:19:44 -0800 (PST)
Date: Thu, 30 Nov 2017 17:19:34 +0100
From: Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>
Subject: Re: BSOD with [PATCH 00/13] mmu_notifier kill invalidate_page
 callback
Message-ID: <20171130161933.GB1606@flask>
References: <20170829235447.10050-1-jglisse@redhat.com>
 <20171130093320.66cxaoj45g2ttzoh@nora.maurer-it.com>
 <39823aee-4918-f87c-8342-89eff622ee43@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <39823aee-4918-f87c-8342-89eff622ee43@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Joerg Roedel <jroedel@suse.de>, Dan Williams <dan.j.williams@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Jack Steiner <steiner@sgi.com>, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, xen-devel@lists.xenproject.org, kvm@vger.kernel.org

2017-11-30 12:20+0100, Paolo Bonzini:
> On 30/11/2017 10:33, Fabian GrA 1/4 nbichler wrote:
> > 
> > It was reverted in 785373b4c38719f4af6775845df6be1dfaea120f after which
> > the symptoms disappeared until this series was merged, which contains
> > 
> > 369ea8242c0fb5239b4ddf0dc568f694bd244de4 mm/rmap: update to new mmu_notifier semantic v2
> > 
> > We haven't bisected the individual commits of the series yet, but the
> > commit immediately preceding its merge exhibits no problems, while
> > everything after does. It is not known whether the bug is actually in
> > the series itself, or whether increasing the likelihood of triggering it
> > is just a side-effect. There is a similar report[2] concerning an
> > upgrade from 4.12.12 to 4.12.13, which does not contain this series in
> > any form AFAICT but might be worth another look as well.
> 
> I know of one issue in this series (invalidate_page was removed from KVM
> without reimplementing it as invalidate_range).  I'll try to prioritize
> the fix, but I don't think I can do it before Monday.

The series also dropped the reloading of the APIC access page and we
never had it in invalidate_range_start ... I'll look into it today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
