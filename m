Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 363BC8E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 15:15:14 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id d35so3879489qtd.20
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 12:15:14 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 16si1775550qvl.219.2019.01.23.12.15.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 12:15:13 -0800 (PST)
Date: Wed, 23 Jan 2019 15:15:06 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 2/4] mm/memory-hotplug: allow memory resources to be
 children
Message-ID: <20190123201506.GG3097@redhat.com>
References: <20190116181859.D1504459@viggo.jf.intel.com>
 <20190116181902.670EEBC3@viggo.jf.intel.com>
 <20190116191635.GD3617@redhat.com>
 <2b52778d-f120-eec7-3e7a-3a9c182170f0@intel.com>
 <20190116233849.GE3617@redhat.com>
 <b1f22eda-b52f-af20-637f-b45971a12d33@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <b1f22eda-b52f-af20-637f-b45971a12d33@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, dave@sr71.net, dan.j.williams@intel.com, dave.jiang@intel.com, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, akpm@linux-foundation.org, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ying.huang@intel.com, fengguang.wu@intel.com, bp@suse.de, bhelgaas@google.com, baiyaowei@cmss.chinamobile.com, tiwai@suse.de

On Wed, Jan 23, 2019 at 12:03:54PM -0800, Dave Hansen wrote:
> On 1/16/19 3:38 PM, Jerome Glisse wrote:
> > So right now i would rather that we keep properly reporting this
> > hazard so that at least we know it failed because of that. This
> > also include making sure that we can not register private memory
> > as a child of an un-busy resource that does exist but might not
> > have yet been claim by its rightful owner.
> 
> I can definitely keep the warning in.  But, I don't think there's a
> chance of HMM registering a IORES_DESC_DEVICE_PRIVATE_MEMORY region as
> the child of another.  The region_intersects() check *should* find that:

Sounds fine to (just keep the warning).

Cheers,
Jérôme

> 
> >         for (; addr > size && addr >= iomem_resource.start; addr -= size) {
> >                 ret = region_intersects(addr, size, 0, IORES_DESC_NONE);
> >                 if (ret != REGION_DISJOINT)
> >                         continue;
> 
