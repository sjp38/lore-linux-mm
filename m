Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9CE696B0253
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 11:48:01 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id g18so2055193itg.1
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 08:48:01 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t8sor3339957oih.321.2017.09.18.08.48.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Sep 2017 08:48:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170918093137.GF32516@quack2.suse.cz>
References: <150277752553.23945.13932394738552748440.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150277753660.23945.11500026891611444016.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170815122701.GF27505@quack2.suse.cz> <CAA9_cmc0vejxCsc1NWp5b4C0CSsO5xetF3t6LCoCuEYB6yPiwQ@mail.gmail.com>
 <20170917173945.GA22200@lst.de> <20170918093137.GF32516@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 18 Sep 2017 08:47:59 -0700
Message-ID: <CAPcyv4g7nv5wma2Nbir15vDZSR_AYKk=wtnxtZh=--qhMJ5DOA@mail.gmail.com>
Subject: Re: [PATCH v4 2/3] mm: introduce MAP_VALIDATE a mechanism for adding
 new mmap flags
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@lst.de>, "Darrick J. Wong" <darrick.wong@oracle.com>, Arnd Bergmann <arnd@arndb.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, david <david@fromorbit.com>

On Mon, Sep 18, 2017 at 2:31 AM, Jan Kara <jack@suse.cz> wrote:
> On Sun 17-09-17 19:39:45, Christoph Hellwig wrote:
>> On Sat, Sep 16, 2017 at 08:44:14PM -0700, Dan Williams wrote:
>> > So it wasn't all that easy, and Linus declined to take it. I think we
>> > should add a new ->mmap_validate() file operation and save the
>> > tree-wide cleanup until later.
>>
>> Note that we already have a mmap_capabilities callout for nommu,
>> I wonder if we could generalize that.
>
> So if I understood Dan right, Linus refused to merge the patch which adds
> 'flags' argument to ->mmap callback. That is actually logically independent
> change from validating flags passed to mmap(2) syscall. Dan did it just to
> save himself from adding a VMA flag for MAP_DIRECT.
>
> For validating flags passed to mmap(2), I agree we could use
> ->mmap_capabilities() instead of mmap_supported_mask Dan has added. But I
> don't have a strong opinion there.

The drawback I see with mmap_capabilities is that it requires all mmap
flags to have a corresponding vm_flag. After the cold reaction the
VM_DAX flag received I'd want to be sure they were on board with this
direction.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
