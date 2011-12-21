Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 3B4A96B004D
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 14:02:50 -0500 (EST)
Received: by werf1 with SMTP id f1so3962233wer.14
        for <linux-mm@kvack.org>; Wed, 21 Dec 2011 11:02:48 -0800 (PST)
Date: Wed, 21 Dec 2011 20:04:33 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [Linaro-mm-sig] [RFC v2 1/2] dma-buf: Introduce dma buffer
 sharing mechanism
Message-ID: <20111221190433.GE3827@phenom.ffwll.local>
References: <1322816252-19955-1-git-send-email-sumit.semwal@ti.com>
 <CAF6AEGtOjO6Z6yfHz-ZGz3+NuEMH2M-8=20U6+-xt-gv9XtzaQ@mail.gmail.com>
 <20111220171437.GC3883@phenom.ffwll.local>
 <201112211727.17104.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201112211727.17104.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Daniel Vetter <daniel@ffwll.ch>, linux@arm.linux.org.uk, "Semwal, Sumit" <sumit.semwal@ti.com>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Rob Clark <robdclark@gmail.com>, linux-arm-kernel@lists.infradead.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-media@vger.kernel.org

On Wed, Dec 21, 2011 at 05:27:16PM +0000, Arnd Bergmann wrote:
> On Tuesday 20 December 2011, Daniel Vetter wrote:
> > It also sounds like that at least for proper userspace mmap support we'd
> > need some dma api extensions on at least arm, and that might take a while
> > ...
> 
> I think it's actually the opposite -- you'd need dma api extensions on
> everything else other than arm, which already has dma_mmap_coherent()
> and dma_mmap_writecombine() for this purpose.

Yeah, that's actually what I wanted to say, but failed at ... Another
thing is that at least for i915, _writecombine isn't what we want actually
because:
- It won't work anyway cause i915 maps stuff cached and does the flushing
  itself and x86 PAT doesn't support mixed mappings (kinda like arm).
- It isn't actually enough, there's another hidden buffer between the
  memory controller interface and the gpu that i915 manually flushes
  (because even a readback on a wc mapping doesn't flush things in there).

So I assume we'll have plenty of funny beating out a good api for cpu
access ;-)

Cheers, Daniel
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
