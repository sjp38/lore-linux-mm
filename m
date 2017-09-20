Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id E77D16B02E1
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 19:22:25 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id e191so7518448ywh.4
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 16:22:25 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id z132si15944yba.377.2017.09.20.16.22.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Sep 2017 16:22:24 -0700 (PDT)
Date: Wed, 20 Sep 2017 16:22:21 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 14/31] vxfs: Define usercopy region in vxfs_inode slab
 cache
Message-ID: <20170920232221.GA18311@infradead.org>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org>
 <1505940337-79069-15-git-send-email-keescook@chromium.org>
 <20170920205642.GA20023@infradead.org>
 <CAGXu5j+hr0UwB5NsvPSKVVfM6NFHHhnNeUZbuwyTRppSOx9Ucw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5j+hr0UwB5NsvPSKVVfM6NFHHhnNeUZbuwyTRppSOx9Ucw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Christoph Hellwig <hch@infradead.org>, LKML <linux-kernel@vger.kernel.org>, David Windsor <dave@nullcore.net>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Network Development <netdev@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Wed, Sep 20, 2017 at 02:21:45PM -0700, Kees Cook wrote:
> This is why I included several other lists on the full CC (am I
> unlucky enough to have you not subscribed to any of them?). Adding a
> CC for everyone can result in a huge CC list, especially for the
> forth-coming 300-patch timer_list series. ;)

If you think the lists are enough to review changes include only
the lists, but don't add CCs for individual patches, that's what
I usually do for cleanups that touch a lot of drivers, but don't
really change actual logic in ever little driver touched.

> Do you want me to resend the full series to you, or would you prefer
> something else like a patchwork bundle? (I'll explicitly add you to CC
> for any future versions, though.)

I'm fine with not being Cced at all if there isn't anything requiring
my urgent personal attention.  It's up to you whom you want to Cc,
but my preference is generally for rather less than more people, and
rather more than less mailing lists.

But the important bit is to Cc a person or mailinglist either on
all patches or on none, otherwise a good review isn't possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
