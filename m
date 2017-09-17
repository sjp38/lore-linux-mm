Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id EE4586B0038
	for <linux-mm@kvack.org>; Sun, 17 Sep 2017 13:39:47 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u138so1589835wmu.2
        for <linux-mm@kvack.org>; Sun, 17 Sep 2017 10:39:47 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 2si4505693wrp.1.2017.09.17.10.39.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Sep 2017 10:39:46 -0700 (PDT)
Date: Sun, 17 Sep 2017 19:39:45 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v4 2/3] mm: introduce MAP_VALIDATE a mechanism for
	adding new mmap flags
Message-ID: <20170917173945.GA22200@lst.de>
References: <150277752553.23945.13932394738552748440.stgit@dwillia2-desk3.amr.corp.intel.com> <150277753660.23945.11500026891611444016.stgit@dwillia2-desk3.amr.corp.intel.com> <20170815122701.GF27505@quack2.suse.cz> <CAA9_cmc0vejxCsc1NWp5b4C0CSsO5xetF3t6LCoCuEYB6yPiwQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA9_cmc0vejxCsc1NWp5b4C0CSsO5xetF3t6LCoCuEYB6yPiwQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, Arnd Bergmann <arnd@arndb.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

On Sat, Sep 16, 2017 at 08:44:14PM -0700, Dan Williams wrote:
> So it wasn't all that easy, and Linus declined to take it. I think we
> should add a new ->mmap_validate() file operation and save the
> tree-wide cleanup until later.

Note that we already have a mmap_capabilities callout for nommu,
I wonder if we could generalize that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
