Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id D9946828F3
	for <linux-mm@kvack.org>; Sun, 10 Jan 2016 18:52:15 -0500 (EST)
Received: by mail-io0-f175.google.com with SMTP id q21so333834497iod.0
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 15:52:15 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id f8si19921389igg.38.2016.01.10.15.52.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 10 Jan 2016 15:52:15 -0800 (PST)
Date: Mon, 11 Jan 2016 08:54:09 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2] virtio_balloon: fix race between migration and
 ballooning
Message-ID: <20160110235409.GA7452@bbox>
References: <1451259313-26353-1-git-send-email-minchan@kernel.org>
 <1451259313-26353-2-git-send-email-minchan@kernel.org>
 <20160101102756-mutt-send-email-mst@redhat.com>
 <20160104002747.GA31090@blaptop.local>
 <20160110233310-mutt-send-email-mst@redhat.com>
MIME-Version: 1.0
In-Reply-To: <20160110233310-mutt-send-email-mst@redhat.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Konstantin Khlebnikov <koct9i@gmail.com>, Rafael Aquini <aquini@redhat.com>, stable@vger.kernel.org

On Sun, Jan 10, 2016 at 11:40:17PM +0200, Michael S. Tsirkin wrote:
> On Mon, Jan 04, 2016 at 09:27:47AM +0900, Minchan Kim wrote:
> > > I think this will cause deadlocks.
> > > 
> > > pages_lock now nests within page lock, balloon_page_putback
> > > nests them in the reverse order.
> > 
> > In balloon_page_dequeu, we used trylock so I don't think it's
> > deadlock.
> 
> I went over this again and I don't see the issue anymore.
> I think I was mistaken, so I dropped my patch and picked
> up yours. Sorry about the noise.

No problem. Thanks for the review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
