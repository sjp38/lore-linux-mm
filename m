Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D287A6B55E3
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 04:00:52 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id q21-v6so6363725pff.21
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 01:00:52 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id k24-v6si9316988pgn.574.2018.08.31.01.00.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Aug 2018 01:00:51 -0700 (PDT)
Date: Sat, 1 Sep 2018 00:39:42 +0800
From: Yi Zhang <yi.z.zhang@linux.intel.com>
Subject: Re: [PATCH V4 4/4] kvm: add a check if pfn is from NVDIMM pmem.
Message-ID: <20180831163941.GA1220@tiger-server>
References: <cover.1534934405.git.yi.z.zhang@linux.intel.com>
 <a4183c0f0adfb6d123599dd306062fd193e83f5a.1534934405.git.yi.z.zhang@linux.intel.com>
 <4192066a-79f3-2b3e-386f-c4ec9b6dd8fd@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <4192066a-79f3-2b3e-386f-c4ec9b6dd8fd@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan.j.williams@intel.com, dave.jiang@intel.com, yu.c.zhang@intel.com, pagupta@redhat.com, david@redhat.com, jack@suse.cz, hch@lst.de, linux-mm@kvack.org, rkrcmar@redhat.com, jglisse@redhat.com, yi.z.zhang@intel.com

On 2018-08-30 at 12:07:11 -0700, Dave Hansen wrote:
> On 08/22/2018 03:58 AM, Zhang Yi wrote:
> >  bool kvm_is_reserved_pfn(kvm_pfn_t pfn)
> >  {
> > -	if (pfn_valid(pfn))
> > -		return PageReserved(pfn_to_page(pfn));
> > +	struct page *page;
> > +
> > +	if (pfn_valid(pfn)) {
> > +		page = pfn_to_page(pfn);
> > +		return PageReserved(page) && !is_dax_page(page);
> > +	}
> 
> This is in desperate need of commenting about what it is doing and why.
> 
> The changelog alone doesn't cut it.
Thanks, Dave, Will add some comments
