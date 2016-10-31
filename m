Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7F9CD6B0290
	for <linux-mm@kvack.org>; Mon, 31 Oct 2016 11:25:56 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id r13so96941811pag.1
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 08:25:56 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id r144si25189230pfr.254.2016.10.31.08.25.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Oct 2016 08:25:55 -0700 (PDT)
Date: Mon, 31 Oct 2016 08:25:19 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 00/60] block: support multipage bvec
Message-ID: <20161031152519.GA25791@infradead.org>
References: <1477728600-12938-1-git-send-email-tom.leiming@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1477728600-12938-1-git-send-email-tom.leiming@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <tom.leiming@gmail.com>
Cc: Jens Axboe <axboe@fb.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Bart Van Assche <bart.vanassche@sandisk.com>, "open list:GFS2 FILE SYSTEM" <cluster-devel@redhat.com>, Coly Li <colyli@suse.de>, Dan Williams <dan.j.williams@intel.com>, "open list:DEVICE-MAPPER  (LVM)" <dm-devel@redhat.com>, "open list:DRBD DRIVER" <drbd-dev@lists.linbit.com>, Eric Wheeler <git@linux.ewheeler.net>, Guoqing Jiang <gqjiang@suse.com>, Hannes Reinecke <hare@suse.com>, Hannes Reinecke <hare@suse.de>, Jiri Kosina <jkosina@suse.cz>, Joe Perches <joe@perches.com>, Johannes Berg <johannes.berg@intel.com>, Johannes Thumshirn <jthumshirn@suse.de>, Keith Busch <keith.busch@intel.com>, Kent Overstreet <kent.overstreet@gmail.com>, Kent Overstreet <kmo@daterainc.com>, "open list:BCACHE (BLOCK LAYER CACHE)" <linux-bcache@vger.kernel.org>, "open list:BTRFS FILE SYSTEM" <linux-btrfs@vger.kernel.org>, "open list:EXT4 FILE SYSTEM" <linux-ext4@vger.kernel.org>, "open list:F2FS FILE SYSTEM" <linux-f2fs-devel@lists.sourceforge.net>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, "open list:NVM EXPRESS TARGET DRIVER" <linux-nvme@lists.infradead.org>, "open list:SUSPEND TO RAM" <linux-pm@vger.kernel.org>, "open list:SOFTWARE RAID (Multiple Disks) SUPPORT" <linux-raid@vger.kernel.org>, "open list:TARGET SUBSYSTEM" <linux-scsi@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, "open list:LogFS" <logfs@logfs.org>, Michal Hocko <mhocko@suse.com>, Mike Christie <mchristi@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Minchan Kim <minchan@kernel.org>, Minfei Huang <mnghuan@gmail.com>, "open list:OSD LIBRARY and FILESYSTEM" <osd-dev@open-osd.org>, Petr Mladek <pmladek@suse.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Takashi Iwai <tiwai@suse.de>, "open list:TARGET SUBSYSTEM" <target-devel@vger.kernel.org>, Toshi Kani <toshi.kani@hpe.com>, Yijing Wang <wangyijing@huawei.com>, Zheng Liu <gnehzuil.liu@gmail.com>, Zheng Liu <wenqing.lz@taobao.com>

Hi Ming,

can you send a first patch just doing the obvious cleanups like
converting to bio_add_page and replacing direct poking into the
bio with the proper accessors?  That should help reducing the
actual series to a sane size, and it should also help to cut
down the Cc list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
