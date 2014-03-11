Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3482F6B0035
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 17:40:25 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id i8so10427862qcq.3
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 14:40:24 -0700 (PDT)
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net. [2001:4b98:c:538::196])
        by mx.google.com with ESMTPS id x6si11940077qas.154.2014.03.11.14.40.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 14:40:24 -0700 (PDT)
Date: Tue, 11 Mar 2014 14:40:14 -0700
From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: mmotm 2014-03-10-15-35 uploaded (virtio_balloon)
Message-ID: <20140311214014.GA18708@leaf>
References: <20140310223701.0969C31C2AA@corp2gmr1-1.hot.corp.google.com>
 <531F43F2.1030504@infradead.org>
 <20140311110338.333e1ee691cadb0f20dbb083@linux-foundation.org>
 <20140311192046.GA2686@leaf>
 <20140311123133.f40adf3154452e82aecb61ca@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140311123133.f40adf3154452e82aecb61ca@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Randy Dunlap <rdunlap@infradead.org>, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, virtio-dev@lists.oasis-open.org, "Michael S. Tsirkin" <mst@redhat.com>

On Tue, Mar 11, 2014 at 12:31:33PM -0700, Andrew Morton wrote:
> On Tue, 11 Mar 2014 12:20:46 -0700 Josh Triplett <josh@joshtriplett.org> wrote:
> 
> > > > ERROR: "balloon_devinfo_alloc" [drivers/virtio/virtio_balloon.ko] undefined!
> > > > ERROR: "balloon_page_enqueue" [drivers/virtio/virtio_balloon.ko] undefined!
> > > > ERROR: "balloon_page_dequeue" [drivers/virtio/virtio_balloon.ko] undefined!
> > > > 
> > > > when loadable module
> > > > 
> > > > or
> > > > 
> > > > virtio_balloon.c:(.text+0x1fa26): undefined reference to `balloon_page_enqueue'
> > > > virtio_balloon.c:(.text+0x1fb87): undefined reference to `balloon_page_dequeue'
> > > > virtio_balloon.c:(.text+0x1fdf1): undefined reference to `balloon_devinfo_alloc'
> > > > 
> > > > when builtin.
> > > 
> > > OK, thanks, I'll drop
> > > http://ozlabs.org/~akpm/mmots/broken-out/mm-disable-mm-balloon_compactionc-completely-when-config_balloon_compaction.patch
> > 
> > Sorry about that; I missed that case in my testing.  It always seems
> > strange that the dependency goes that way around.
> > 
> > With virtio-balloon being the one and only user of this API, would it be
> > reasonable to just only compile in balloon_compaction.o when
> > CONFIG_VIRTIO_BALLOON?
> 
> Better to make VIRTIO_BALLOON depend on (or select) BALLOON_COMPACTION.

I'd love to do that, but as far as I can tell, VIRTIO_BALLOON has gone
out of its way to support !CONFIG_BALLOON_COMPACTION.

Could someone who works on VIRTIO_BALLOON provide some details here
about the distinction?

- Josh Triplett

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
