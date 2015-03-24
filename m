Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5CAD56B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 02:53:30 -0400 (EDT)
Received: by wgbcc7 with SMTP id cc7so163302991wgb.0
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 23:53:29 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTP id dn7si5089588wjb.44.2015.03.23.23.53.28
        for <linux-mm@kvack.org>;
        Mon, 23 Mar 2015 23:53:28 -0700 (PDT)
Date: Tue, 24 Mar 2015 07:53:25 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 11/12] fs: don't reassign dirty inodes to
	default_backing_dev_info
Message-ID: <20150324065325.GC3159@lst.de>
References: <1421228561-16857-1-git-send-email-hch@lst.de> <1421228561-16857-12-git-send-email-hch@lst.de> <CAMM=eLe6Tt+g7dLcnn5a1fQboDknkasazsMiOFBziWPZemnYtg@mail.gmail.com> <20150323224012.GA29505@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150323224012.GA29505@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Snitzer <snitzer@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, David Howells <dhowells@redhat.com>, linux-nfs@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@fb.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, device-mapper development <dm-devel@redhat.com>, linux-mtd@lists.infradead.org, Tejun Heo <tj@kernel.org>, ceph-devel@vger.kernel.org, Jeff Moyer <jmoyer@redhat.com>

On Mon, Mar 23, 2015 at 06:40:13PM -0400, Mike Snitzer wrote:
> FYI, here is the DM fix I've staged for 4.0-rc6.  I'll continue testing
> the various DM targets before requesting Linus to pull.

Yeah, from looking at the bugzilla it seemed like dm was releasing the
dev_t before the queue has been freed.

I don't know this code to well, so this isn't a full review, but it looks like
the right fix to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
