Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 63CBE6B026F
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 03:40:03 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id d1-v6so1718298wrr.4
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 00:40:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l14-v6sor232265wmh.68.2018.07.24.00.40.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 00:40:02 -0700 (PDT)
Date: Tue, 24 Jul 2018 09:39:58 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v6 00/13] mm: Teach memory_failure() about ZONE_DEVICE
 pages
Message-ID: <20180724073958.GB15984@gmail.com>
References: <153154376846.34503.15480221419473501643.stgit@dwillia2-desk3.amr.corp.intel.com>
 <b9602b1b-97d3-b9c1-cc85-5b73b67e2e03@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b9602b1b-97d3-b9c1-cc85-5b73b67e2e03@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jiang <dave.jiang@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Tony Luck <tony.luck@intel.com>, Jan Kara <jack@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, x86@kernel.org, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Borislav Petkov <bp@alien8.de>, Matthew Wilcox <willy@infradead.org>, "H. Peter Anvin" <hpa@zytor.com>, linux-fsdevel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Christoph Hellwig <hch@lst.de>, linux-edac@vger.kernel.org


* Dave Jiang <dave.jiang@intel.com> wrote:

> Ingo,
> Is it possible to ack the x86 bits in this patch series? I'm hoping to
> get this pulled through the libnvdimm tree for 4.19. Thanks!

With the minor typo fixed in the first patch, both patches are looking good to me:

  Acked-by: Ingo Molnar <mingo@kernel.org>

Assuming that it gets properly tested, etc.

Thanks,

	Ingo
