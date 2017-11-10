Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4929C280275
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 04:07:00 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id e8so304656wmc.2
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 01:07:00 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id b24si8631915wrg.487.2017.11.10.01.06.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 01:06:59 -0800 (PST)
Date: Fri, 10 Nov 2017 10:06:58 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 13/15] mm, devmap: introduce CONFIG_DEVMAP_MANAGED_PAGES
Message-ID: <20171110090658.GD4895@lst.de>
References: <150949209290.24061.6283157778959640151.stgit@dwillia2-desk3.amr.corp.intel.com> <150949216597.24061.3943310722702629588.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150949216597.24061.3943310722702629588.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, hch@lst.de

On Tue, Oct 31, 2017 at 04:22:46PM -0700, Dan Williams wrote:
> Combine the now three use cases of page-idle callbacks for ZONE_DEVICE
> memory into a common selectable symbol.

Very sparse changelog.  I understand the Kconfig bit, but it also seems to
introduce new static key functionality that isn't explained at all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
