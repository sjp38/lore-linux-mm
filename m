Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AF3396B05F1
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 08:35:37 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id d5so189787414pfg.3
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 05:35:37 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f13si404043pff.143.2017.07.31.05.35.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 05:35:36 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6VCWG2q041718
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 08:35:36 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2c21x00dk9-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 08:35:35 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Mon, 31 Jul 2017 13:35:32 +0100
Date: Mon, 31 Jul 2017 14:35:21 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [RFC PATCH 0/5] mm, memory_hotplug: allocate memmap from
 hotadded memory
In-Reply-To: <20170728121941.GL2274@dhcp22.suse.cz>
References: <20170726083333.17754-1-mhocko@kernel.org>
	<20170726210657.GE21717@redhat.com>
	<20170727065652.GE20970@dhcp22.suse.cz>
	<20170728121941.GL2274@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20170731143521.5809a6ca@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jerome Glisse <jglisse@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Catalin Marinas <catalin.marinas@arm.com>, Dan Williams <dan.j.williams@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>, gerald.schaefer@de.ibm.com

On Fri, 28 Jul 2017 14:19:41 +0200
Michal Hocko <mhocko@kernel.org> wrote:

> On Thu 27-07-17 08:56:52, Michal Hocko wrote:
> > On Wed 26-07-17 17:06:59, Jerome Glisse wrote:
> > [...]
> > > This does not seems to be an opt-in change ie if i am reading patch 3
> > > correctly if an altmap is not provided to __add_pages() you fallback
> > > to allocating from begining of zone. This will not work with HMM ie
> > > device private memory. So at very least i would like to see some way
> > > to opt-out of this. Maybe a new argument like bool forbid_altmap ?
> > 
> > OK, I see! I will think about how to make a sane api for that.
> 
> This is what I came up with. s390 guys mentioned that I cannot simply
> use the new range at this stage yet. This will need probably some other
> changes but I guess we want an opt-in approach with an arch veto in general.
> 
> So what do you think about the following? Only x86 is update now and I
> will split it into two parts but the idea should be clear at least.

This looks good, and the kernel will also boot again on s390 when applied
on top of the other 5 patches (plus adding the s390 part here).

Regards,
Gerald

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
