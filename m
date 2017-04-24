Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4E1926B03A4
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 14:18:43 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id d79so5319134wma.0
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 11:18:43 -0700 (PDT)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id p2si330369wmb.77.2017.04.24.11.18.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 11:18:42 -0700 (PDT)
Received: by mail-wm0-x231.google.com with SMTP id w64so3972123wma.0
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 11:18:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170424152348.GE9112@infradead.org>
References: <20170424132259.8680-1-jlayton@redhat.com> <20170424132259.8680-6-jlayton@redhat.com>
 <20170424152348.GE9112@infradead.org>
From: Mike Marshall <hubcap@omnibond.com>
Date: Mon, 24 Apr 2017 14:18:41 -0400
Message-ID: <CAOg9mSQPqSVLXqovLiezKycWJ+U2J1UZJ0tO2p8TeKh8WP2S2g@mail.gmail.com>
Subject: Re: [PATCH v3 05/20] orangefs: don't call filemap_write_and_wait from fsync
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Layton <jlayton@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-btrfs@vger.kernel.org, Ext4 Developers List <linux-ext4@vger.kernel.org>, linux-cifs@vger.kernel.org, linux-mm <linux-mm@kvack.org>, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, osd-dev@open-osd.org, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org, David Howells <dhowells@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, jack@suse.com, Al Viro <viro@zeniv.linux.org.uk>, corbet@lwn.net, neilb@suse.de, Chris Mason <clm@fb.com>, Theodore Ts'o <tytso@mit.edu>, Jens Axboe <axboe@kernel.dk>

I've been running it here...

Acked-by: Mike Marshall <hubcap@omnibond.com>

On Mon, Apr 24, 2017 at 11:23 AM, Christoph Hellwig <hch@infradead.org> wrote:
> Looks fine,
>
> Reviewed-by: Christoph Hellwig <hch@lst.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
