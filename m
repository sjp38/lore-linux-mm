Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id B05DC6B004F
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 07:37:44 -0500 (EST)
Received: by wera13 with SMTP id a13so444608wer.14
        for <linux-mm@kvack.org>; Thu, 26 Jan 2012 04:37:43 -0800 (PST)
Date: Thu, 26 Jan 2012 13:37:43 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [Linaro-mm-sig] [PATCH 4/4] dma-buf: Move code out of
 mutex-protected section in dma_buf_attach()
Message-ID: <20120126123743.GH3896@phenom.ffwll.local>
References: <1327577245-20354-1-git-send-email-laurent.pinchart@ideasonboard.com>
 <1327577245-20354-5-git-send-email-laurent.pinchart@ideasonboard.com>
 <e0d58a$3259e0@orsmga002.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e0d58a$3259e0@orsmga002.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Sumit Semwal <sumit.semwal@ti.com>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org

On Thu, Jan 26, 2012 at 12:11:57PM +0000, Chris Wilson wrote:
> On Thu, 26 Jan 2012 12:27:25 +0100, Laurent Pinchart <laurent.pinchart@ideasonboard.com> wrote:
> > Some fields can be set without mutex protection. Initialize them before
> > locking the mutex.
> 
> struct mutex lock is described as
> 
>  /* mutex to serialize list manipulation and other ops */
> 
> maybe now is a good time to be a little more descriptive in what that
> mutex is meant to protect and sprinkle enforcement throughout the code
> as a means of documentation.

As, sore spot there. I think the current locking scheme is rather much
still in flux. I think we need to pull out callbacks to the exporter out
from the dma_buf mutex because otherwise we won't be able to avoid
deadlocks.

I think we'll need to wait for 1-2 exporters to show up in upstream until
we can clarify this. But it is very much on my list.
-Daniel
-- 
Daniel Vetter
Mail: daniel@ffwll.ch
Mobile: +41 (0)79 365 57 48

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
