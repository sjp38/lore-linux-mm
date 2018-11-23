Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9FF616B303F
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 03:47:12 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id o10-v6so15232474plk.16
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 00:47:12 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d17si34724310pfm.40.2018.11.23.00.47.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 00:47:11 -0800 (PST)
Date: Fri, 23 Nov 2018 09:47:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v8 1/7] mm, devm_memremap_pages: Mark
 devm_memremap_pages() EXPORT_SYMBOL_GPL
Message-ID: <20181123084709.GB8625@dhcp22.suse.cz>
References: <154275556908.76910.8966087090637564219.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154275557457.76910.16923571232582744134.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20181122133013.GG18011@dhcp22.suse.cz>
 <20181122163858.GA23809@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181122163858.GA23809@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org

On Thu 22-11-18 17:38:58, Christoph Hellwig wrote:
> On Thu, Nov 22, 2018 at 02:30:13PM +0100, Michal Hocko wrote:
> > Whoever needs a wrapper around arch_add_memory can do so because this
> > symbol has no restriction for the usage.
> 
> arch_add_memory is not exported, and it really should not be.

It is not, but nobody really prevents from wrapping it and exporting.
I am definitely not arguing for that and I would even agree with you
that it shouldn't be exported at all unless there is a _very_ good
reason for that. Because usecases is what we care about here.

-- 
Michal Hocko
SUSE Labs
