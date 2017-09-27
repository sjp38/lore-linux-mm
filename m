Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id E79D96B0261
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 11:55:01 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id b184so18998562oii.1
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 08:55:01 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k145sor4229966oih.91.2017.09.27.08.55.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Sep 2017 08:55:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170927153918.GA24314@linux.intel.com>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com>
 <20170925231404.32723-7-ross.zwisler@linux.intel.com> <CAPcyv4jtO028KeZK7SdkOUsgMLGqgttLzBCYgH0M+RP3eAXf4A@mail.gmail.com>
 <20170926185751.GB31146@linux.intel.com> <CAPcyv4iVc9y8PE24ZvkiBYdp4Die0Q-K5S6QexW_6YQ_M0F4QA@mail.gmail.com>
 <20170926210645.GA7798@linux.intel.com> <CAPcyv4iDTNteQAt1bBHCGijwsk45rJWHfdr+e_rOwK39jpC2Og@mail.gmail.com>
 <20170927113527.GD25746@quack2.suse.cz> <20170927153918.GA24314@linux.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 27 Sep 2017 08:54:59 -0700
Message-ID: <CAPcyv4gXt673Jz2__t7LwvaFrRGxa5czgoB-b8kdjAfOETAH9Q@mail.gmail.com>
Subject: Re: [PATCH 6/7] mm, fs: introduce file_operations->post_mmap()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-xfs@vger.kernel.org

On Wed, Sep 27, 2017 at 8:39 AM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> On Wed, Sep 27, 2017 at 01:35:27PM +0200, Jan Kara wrote:
[..]
>> Hum, this is an interesting option. So do you suggest that filesystems
>> supporting DAX would always setup mappings with VM_MIXEDMAP and without
>> VM_HUGEPAGE and thus we'd get rid of dependency on S_DAX flag in ->mmap?
>> That could actually work. The only possible issue I can see is that
>> VM_MIXEDMAP is still slightly different from normal page mappings and it
>> could have some performance implications - e.g. copy_page_range() does more
>> work on VM_MIXEDMAP mappings but not on normal page mappings.
>
> It looks like having VM_MIXEDMAP always set for filesystems that support DAX
> might affect their memory's NUMA migration in the non-DAX case?
>
> 8e76d4e sched, numa: do not hint for NUMA balancing on VM_MIXEDMAP mappings

Addressed separately here:

c1ef8e2c0235 mm: disable numa migration faults for dax vmas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
