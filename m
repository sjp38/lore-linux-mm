Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8C9096B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 13:08:55 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id c33so7769759ote.1
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 10:08:55 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s40si1271341ote.464.2017.12.19.10.08.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 10:08:54 -0800 (PST)
Date: Tue, 19 Dec 2017 20:08:41 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v20 0/7] Virtio-balloon Enhancement
Message-ID: <20171219200726-mutt-send-email-mst@kernel.org>
References: <1513685879-21823-1-git-send-email-wei.w.wang@intel.com>
 <201712192305.AAE21882.MtQHJOFFSFVOLO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201712192305.AAE21882.MtQHJOFFSFVOLO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On Tue, Dec 19, 2017 at 11:05:11PM +0900, Tetsuo Handa wrote:
> Wei Wang wrote:
> > ChangeLog:
> > v19->v20:
> > 1) patch 1: xbitmap
> > 	- add __rcu to "void **slot";
> > 	- remove the exceptional path.
> > 2) patch 3: xbitmap
> > 	- DeveloperNotes: add an item to comment that the current bit range
> > 	  related APIs operating on extremely large ranges (e.g.
> >           [0, ULONG_MAX)) will take too long time. This can be optimized in
> > 	  the future.
> > 	- remove the exceptional path;
> > 	- remove xb_preload_and_set();
> > 	- reimplement xb_clear_bit_range to make its usage close to
> > 	  bitmap_clear;
> > 	- rename xb_find_next_set_bit to xb_find_set, and re-implement it
> > 	  in a style close to find_next_bit;
> > 	- rename xb_find_next_zero_bit to xb_find_clear, and re-implement
> > 	  it in a stytle close to find_next_zero_bit;
> > 	- separate the implementation of xb_find_set and xb_find_clear for
> > 	  the convenience of future updates.
> 
> Removing exceptional path made this patch easier to read.
> But what I meant is
> 
>   Can you eliminate exception path and fold all xbitmap patches into one, and
>   post only one xbitmap patch without virtio-balloon changes? 

And then people will complain that patch is too big
and hard to understand without any users.

As long as patches don't change the same lines of code,
it's fine to split up imho. In this case it's done
to attribute code better, seems like a reasonable thing to do
to me.

> .
> 
> I still think we don't need xb_preload()/xb_preload_end().
> I think xb_find_set() has a bug in !node path.
> 
> Also, please avoid unconditionally adding to builtin modules.
> There are users who want to save even few KB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
