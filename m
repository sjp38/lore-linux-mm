Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 135996B0388
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 14:35:46 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id w67so8447792wmd.3
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 11:35:46 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id c15si3637400wrd.188.2017.02.28.11.35.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 11:35:43 -0800 (PST)
Date: Tue, 28 Feb 2017 19:35:39 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH RESEND] drm/via: use get_user_pages_unlocked()
Message-ID: <20170228193539.GT29622@ZenIV.linux.org.uk>
References: <20170227215008.21457-1-lstoakes@gmail.com>
 <20170228090110.m4pxtjlbgaft7oet@phenom.ffwll.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170228090110.m4pxtjlbgaft7oet@phenom.ffwll.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org

On Tue, Feb 28, 2017 at 10:01:10AM +0100, Daniel Vetter wrote:

> > +	ret = get_user_pages_unlocked((unsigned long)xfer->mem_addr,
> > +			vsg->num_pages, vsg->pages,
> > +			(vsg->direction == DMA_FROM_DEVICE) ? FOLL_WRITE : 0);

Umm...  Why not
	ret = get_user_pages_fast((unsigned long)xfer->mem_addr,
			vsg->num_pages,
			vsg->direction == DMA_FROM_DEVICE,
			vsg->pages);

IOW, do you really need a warranty that ->mmap_sem will be grabbed and
released?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
