Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id B7F7B6B02AA
	for <linux-mm@kvack.org>; Wed, 30 May 2018 07:03:02 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id i1-v6so15182713ioh.15
        for <linux-mm@kvack.org>; Wed, 30 May 2018 04:03:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 189-v6sor3583755itl.72.2018.05.30.04.03.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 May 2018 04:03:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <8a9e048b-f60c-90bc-6884-e2fa6eca2c28@redhat.com>
References: <20180523144357.18985-1-hch@lst.de> <20180523144357.18985-12-hch@lst.de>
 <20180530055033.GZ30110@magnolia> <bc621d7c-f1a6-14c2-663f-57ded16811fa@redhat.com>
 <20180530095911.GB31068@lst.de> <e14b3cfb-73ca-e712-e1e9-4ceabc8c7b6d@redhat.com>
 <20180530101003.GA31419@lst.de> <8a9e048b-f60c-90bc-6884-e2fa6eca2c28@redhat.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Wed, 30 May 2018 13:03:00 +0200
Message-ID: <CAHc6FU7We19b5m2eXq2HKN=4szM+mgfyv6COMZzjAdxRyj0SKg@mail.gmail.com>
Subject: Re: [Cluster-devel] [PATCH 11/34] iomap: move IOMAP_F_BOUNDARY to gfs2
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, cluster-devel <cluster-devel@redhat.com>, linux-mm@kvack.org

On 30 May 2018 at 12:12, Steven Whitehouse <swhiteho@redhat.com> wrote:
> Hi,
>
> On 30/05/18 11:10, Christoph Hellwig wrote:
>>
>> On Wed, May 30, 2018 at 11:02:08AM +0100, Steven Whitehouse wrote:
>>>
>>> In that case,  maybe it would be simpler to drop it for GFS2. Unless we
>>> are getting a lot of benefit from it, then we should probably just follow
>>> the generic pattern here. Eventually we'll move everything to iomap, so
>>> that the bh mapping interface will be gone. That implies that we might be
>>> able to drop it now, to avoid this complication during the conversion.
>>>
>>> Andreas, do you see any issues with that?

We're not handling reads through iomap yet, so I'd be happier with
keeping that flag in one form or the other until we get there. This
will go away eventually anyway.

>> I suspect it actually is doing the wrong thing today.  It certainly
>> does for SSDs, and it probably doesn't do a useful thing for modern
>> disks with intelligent caches either.
>
>
> Yes, agreed that it makes no sense for SSDs,

Thanks,
Andreas
