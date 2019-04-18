Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5A18C282DA
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 02:09:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7EEB72183E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 02:09:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="sWBJ4MP4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7EEB72183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 026386B0007; Wed, 17 Apr 2019 22:09:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F16756B0008; Wed, 17 Apr 2019 22:09:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E04DE6B000A; Wed, 17 Apr 2019 22:09:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id B53E06B0007
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 22:09:25 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id f11so350659otl.20
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 19:09:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=WrLS7c6kahvwclZJMhG+EEBp9/3p/FOJcV7sIRhk688=;
        b=nV9qfhGEY42e5EP7u+BxYAV0w6i0RgfAA08q0VIPtFBuzvzXBxEDGc5hOfUFovB2qK
         1RkxqY5RKbOZ9p0jRkTPm8bY33Xzn9cZMSoDYmNNis8E0GH01VPhxF3wD8n6g5fqEwuQ
         /pZoWhgk67oD5qrWrpsnYXZwgQ28iNBixi7tiluvz70ZrusxO2R014nQfjsKtuAAEwFM
         w5l+k1TBQOVMIsXreE+jTzmdlbyFg/2pkGalpYEHNV9kcKa8tEyi3SFDynsablDAtH+G
         dAMfhA5QjjhL2IJ9O+RHDALntIjVMbPLFMJlilgQdbtGiNfJvkCyZFexmKpQUNNVuY8l
         tQ1A==
X-Gm-Message-State: APjAAAU++9V0+sIMjFDCAqz32TxnnYYjAQlK5iEjhP4QZNPYxv2qIEB8
	6UpK9hKBcHoEiVxbU2e4IIkDDW+m0tY37Qehl2TEGA3yGHtVSfDC20oHbneMPYwxDcaiHEf4O5/
	N6AFEURm8+cEQ4i7gj2Blgb5ahI4AHzQdjxcuTiOXgJIgj4enh3+E46DW9gRmDv5XNg==
X-Received: by 2002:a05:6830:16c3:: with SMTP id l3mr2141046otr.359.1555553365414;
        Wed, 17 Apr 2019 19:09:25 -0700 (PDT)
X-Received: by 2002:a05:6830:16c3:: with SMTP id l3mr2141028otr.359.1555553364779;
        Wed, 17 Apr 2019 19:09:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555553364; cv=none;
        d=google.com; s=arc-20160816;
        b=0MKlXV9Y0qUoPGMLmqDmspF0HIp1TGAjbKbb+IkEst+LFNzg2CKmRLCcsEcvu1PRVS
         v9MDeSgZSxd6ZacYu7gOPm/aEILv/nuxsqRqEgD2yeNptrLp/asfL11KDqaf9KxGVmBZ
         anlZ8qgTt24b8m5O4V7jWXCxXxhBMD7PbxV/gXMt9Itcqj5PDppfAyezKjmO1CdIxSjr
         /Iy+H7uCK33BJXEQJHAxWnBimuJSAgIBWKjAfjJLmlv9R+XQrkEEbvlXYYhHVG2WCYHe
         QCwrgMWq/rmch99IUclxiOMySbDlMCyYcwq5zlsQGgvvLIZVjewH4CrtnT5ixiepL7uN
         q0Rw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=WrLS7c6kahvwclZJMhG+EEBp9/3p/FOJcV7sIRhk688=;
        b=Dil6Vg720KCx2R+CAcrjmXXQDtWHsxzgNRLl1Uxp7SMY1YzT/t98rULx/yE6mSefTf
         PkmwsBI80L2qXK8S9IdbaZ/OA62rRz96EGeLvN0C1N7cBi12tO3V6f/G8ra7bSv6fHAK
         0vv9era8Zvdbr6++M7gdng98CbxeV7vCTKnL23ZiV72oUNvWH9SzJKdZybcT3C/PTj6Z
         hI+33+HJQvF+TEwWWOD27hNf9tEV//nmZVHczVIwarRYeglnEpMj6RVe6M3BsQndUIN+
         ZhUyrfez/WnGNFiXzoO8147jsL1Ayft7CTpIlOiz08+ckn/0u2Rc6b1LNmB6Hv/zgaI3
         Preg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=sWBJ4MP4;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o4sor247021oia.24.2019.04.17.19.09.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 19:09:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=sWBJ4MP4;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=WrLS7c6kahvwclZJMhG+EEBp9/3p/FOJcV7sIRhk688=;
        b=sWBJ4MP4aMbDjfMOL2XmESU3BP1NUeCYIIgWZvm8bnnn2yTsIA4nOkaJ4ujF3TGAQL
         V7Bvewsg7Z+zFnK7uufCUElZo1lFGESS6DPnGlrzZo57bY7JtK/xauERnePYfPo1QDVH
         R7W5isQJDZBGsz+/Z/QRdBGGahMkJ1wjjC/51vqskOVhveFg3ETdoXFkYfJhvFyO/VY1
         Oh8zwzYpMOaFxrQ92EVfnBRB7oY6ydppKS6DaSBozcTfRk8OJTF/q5RivIIZBRulYXFf
         qnEnAcBSLCYeKnMyRYBUwzt0WqFSYWJSm9HihsaqQE6JrXV5WOCM6wal7q8J1yD08aXs
         o12A==
X-Google-Smtp-Source: APXvYqxBRLry2uehHtUIkQ1eBS/Fg07FCXB2FZ6fmtn5pcgldkBocOuARUVj5a3Sv2b8a/RLFyKNOhEvUY0nxxYuSLU=
X-Received: by 2002:aca:f581:: with SMTP id t123mr443431oih.0.1555553364394;
 Wed, 17 Apr 2019 19:09:24 -0700 (PDT)
MIME-Version: 1.0
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190417150331.90219ca42a1c0db8632d0fd5@linux-foundation.org> <CAPcyv4hB47NJrVi1sm+7msL+6dJNhBD10BJbtLPZRcK2JK6+pg@mail.gmail.com>
In-Reply-To: <CAPcyv4hB47NJrVi1sm+7msL+6dJNhBD10BJbtLPZRcK2JK6+pg@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 17 Apr 2019 19:09:12 -0700
Message-ID: <CAPcyv4iW=xhhUQbg0bt=xCgVaR_jUvATeLxSoCfvzG5gTEAX6A@mail.gmail.com>
Subject: Re: [PATCH v6 00/12] mm: Sub-section memory hotplug support
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Hildenbrand <david@redhat.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Logan Gunthorpe <logang@deltatee.com>, Toshi Kani <toshi.kani@hpe.com>, Jeff Moyer <jmoyer@redhat.com>, 
	Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, stable <stable@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, osalvador@suse.de
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 3:59 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Wed, Apr 17, 2019 at 3:04 PM Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > On Wed, 17 Apr 2019 11:38:55 -0700 Dan Williams <dan.j.williams@intel.com> wrote:
> >
> > > The memory hotplug section is an arbitrary / convenient unit for memory
> > > hotplug. 'Section-size' units have bled into the user interface
> > > ('memblock' sysfs) and can not be changed without breaking existing
> > > userspace. The section-size constraint, while mostly benign for typical
> > > memory hotplug, has and continues to wreak havoc with 'device-memory'
> > > use cases, persistent memory (pmem) in particular. Recall that pmem uses
> > > devm_memremap_pages(), and subsequently arch_add_memory(), to allocate a
> > > 'struct page' memmap for pmem. However, it does not use the 'bottom
> > > half' of memory hotplug, i.e. never marks pmem pages online and never
> > > exposes the userspace memblock interface for pmem. This leaves an
> > > opening to redress the section-size constraint.
> >
> > v6 and we're not showing any review activity.  Who would be suitable
> > people to help out here?
>
> There was quite a bit of review of the cover letter from Michal and
> David, but you're right the details not so much as of yet. I'd like to
> call out other people where I can reciprocate with some review of my
> own. Oscar's altmap work looks like a good candidate for that.

I'm also hoping Jeff can give a tested-by for the customer scenarios
that fall over with the current implementation.

