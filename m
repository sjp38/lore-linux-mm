Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 72DE96B2C28
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 11:39:00 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id b141-v6so9334730wme.4
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 08:39:00 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id q18si24965513wro.137.2018.11.22.08.38.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 08:38:58 -0800 (PST)
Date: Thu, 22 Nov 2018 17:38:58 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v8 1/7] mm, devm_memremap_pages: Mark
 devm_memremap_pages() EXPORT_SYMBOL_GPL
Message-ID: <20181122163858.GA23809@lst.de>
References: <154275556908.76910.8966087090637564219.stgit@dwillia2-desk3.amr.corp.intel.com> <154275557457.76910.16923571232582744134.stgit@dwillia2-desk3.amr.corp.intel.com> <20181122133013.GG18011@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181122133013.GG18011@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@lst.de>, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org

On Thu, Nov 22, 2018 at 02:30:13PM +0100, Michal Hocko wrote:
> Whoever needs a wrapper around arch_add_memory can do so because this
> symbol has no restriction for the usage.

arch_add_memory is not exported, and it really should not be.
