Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id E83776B0039
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 08:55:07 -0400 (EDT)
Received: by mail-ig0-f178.google.com with SMTP id hn18so7142025igb.17
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 05:55:07 -0700 (PDT)
Received: from mail-ie0-x234.google.com (mail-ie0-x234.google.com [2607:f8b0:4001:c03::234])
        by mx.google.com with ESMTPS id i15si8754624igt.44.2014.09.02.05.55.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Sep 2014 05:55:07 -0700 (PDT)
Received: by mail-ie0-f180.google.com with SMTP id rl12so7310642iec.25
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 05:55:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140902012222.GA21405@infradead.org>
References: <CAEp=YLgzsLbmEfGB5YKVcHP4CQ-_z1yxnZ0tpo7gjKZ2e1ma5g@mail.gmail.com>
	<20140902000822.GA20473@dastard>
	<20140902012222.GA21405@infradead.org>
Date: Tue, 2 Sep 2014 08:55:07 -0400
Message-ID: <CAA8KC9Lgjf_FBXnKAaJtp6=NCWsoCFOobgi5b84BXfAcbgynJQ@mail.gmail.com>
Subject: Re: ext4 vs btrfs performance on SSD array
From: Zack Coffey <clickwir@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-raid@vger.kernel.org, linux-mm@kvack.org

While I'm sure some of those settings were selected with good reason,
maybe there can be a few options (2 or 3) that have some basic
intelligence at creation to pick a more sane option.

Some checks to see if an option or two might be better suited for the
fs. Like the RAID5 stripe size. Leave the default as is, but maybe a
quick speed test to automatically choose from a handful of the most
common values. If they fail or nothing better is found, then apply the
default value just like it would now.


On Mon, Sep 1, 2014 at 9:22 PM, Christoph Hellwig <hch@infradead.org> wrote:
> On Tue, Sep 02, 2014 at 10:08:22AM +1000, Dave Chinner wrote:
>> Pretty obvious difference: avgrq-sz. btrfs is doing 512k IOs, ext4
>> and XFS are doing is doing 128k IOs because that's the default block
>> device readahead size.  'blockdev --setra 1024 /dev/sdd' before
>> mounting the filesystem will probably fix it.
>
> Btw, it's really getting time to make Linux storage fs work out the
> box.  There's way to many things that are stupid by default and we
> require everyone to fix up manually:
>
>  - the ridiculously low max_sectors default
>  - the very small max readahead size
>  - replacing cfq with deadline (or noop)
>  - the too small RAID5 stripe cache size
>
> and probably a few I forgot about.  It's time to make things perform
> well out of the box..
> --
> To unsubscribe from this list: send the line "unsubscribe linux-btrfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
