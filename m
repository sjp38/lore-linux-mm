Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2D0696B029E
	for <linux-mm@kvack.org>; Mon, 31 Oct 2016 18:52:10 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id x186so23014193vkd.1
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 15:52:10 -0700 (PDT)
Received: from mail-vk0-x235.google.com (mail-vk0-x235.google.com. [2607:f8b0:400c:c05::235])
        by mx.google.com with ESMTPS id h191si12381421vka.148.2016.10.31.15.52.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Oct 2016 15:52:09 -0700 (PDT)
Received: by mail-vk0-x235.google.com with SMTP id w194so50319279vkw.2
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 15:52:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161031152519.GA25791@infradead.org>
References: <1477728600-12938-1-git-send-email-tom.leiming@gmail.com> <20161031152519.GA25791@infradead.org>
From: Ming Lei <tom.leiming@gmail.com>
Date: Tue, 1 Nov 2016 06:52:08 +0800
Message-ID: <CACVXFVN7Cnf8CqsnQwJEeOJTQr=qmHWLrieO++0XXcK3=mWQCw@mail.gmail.com>
Subject: Re: [PATCH 00/60] block: support multipage bvec
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jens Axboe <axboe@fb.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-block <linux-block@vger.kernel.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Bart Van Assche <bart.vanassche@sandisk.com>, "open list:GFS2 FILE SYSTEM" <cluster-devel@redhat.com>, Coly Li <colyli@suse.de>, Dan Williams <dan.j.williams@intel.com>, "open list:DEVICE-MAPPER (LVM)" <dm-devel@redhat.com>, "open list:DRBD DRIVER" <drbd-dev@lists.linbit.com>, Eric Wheeler <git@linux.ewheeler.net>, Guoqing Jiang <gqjiang@suse.com>, Hannes Reinecke <hare@suse.com>, Hannes Reinecke <hare@suse.de>, Jiri Kosina <jkosina@suse.cz>, Joe Perches <joe@perches.com>, Johannes Berg <johannes.berg@intel.com>, Johannes Thumshirn <jthumshirn@suse.de>, Keith Busch <keith.busch@intel.com>, Kent Overstreet <kent.overstreet@gmail.com>, Kent Overstreet <kmo@daterainc.com>, "open list:BCACHE (BLOCK LAYER CACHE)" <linux-bcache@vger.kernel.org>, "open list:BTRFS FILE SYSTEM" <linux-btrfs@vger.kernel.org>, "open list:EXT4 FILE SYSTEM" <linux-ext4@vger.kernel.org>, "open list:F2FS FILE SYSTEM" <linux-f2fs-devel@lists.sourceforge.net>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, "open list:NVM EXPRESS TARGET DRIVER" <linux-nvme@lists.infradead.org>, "open list:SUSPEND TO RAM" <linux-pm@vger.kernel.org>, "open list:SOFTWARE RAID (Multiple Disks) SUPPORT" <linux-raid@vger.kernel.org>, "open list:TARGET SUBSYSTEM" <linux-scsi@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, "open list:LogFS" <logfs@logfs.org>, Michal Hocko <mhocko@suse.com>, Mike Christie <mchristi@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Minchan Kim <minchan@kernel.org>, Minfei Huang <mnghuan@gmail.com>, "open list:OSD LIBRARY and FILESYSTEM" <osd-dev@open-osd.org>, Petr Mladek <pmladek@suse.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Takashi Iwai <tiwai@suse.de>, "open list:TARGET SUBSYSTEM" <target-devel@vger.kernel.org>, Toshi Kani <toshi.kani@hpe.com>, Yijing Wang <wangyijing@huawei.com>, Zheng Liu <gnehzuil.liu@gmail.com>, Zheng Liu <wenqing.lz@taobao.com>

On Mon, Oct 31, 2016 at 11:25 PM, Christoph Hellwig <hch@infradead.org> wrote:
> Hi Ming,
>
> can you send a first patch just doing the obvious cleanups like
> converting to bio_add_page and replacing direct poking into the
> bio with the proper accessors?  That should help reducing the

OK, that is just the 1st part of the patchset.

> actual series to a sane size, and it should also help to cut
> down the Cc list.
>



Thanks,
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
