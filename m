Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na6sys010bmx109.postini.com [74.125.246.209])
	by kanga.kvack.org (Postfix) with SMTP id E91AF6B005C
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 10:17:05 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so3392775vbb.14
        for <linux-mm@kvack.org>; Mon, 09 Jan 2012 07:17:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAAQKjZMEsuib18RYE7OvZPUqhKnvrZ8i3+EMuZSXr9KPVygo_Q@mail.gmail.com>
References: <1322816252-19955-1-git-send-email-sumit.semwal@ti.com>
	<1322816252-19955-2-git-send-email-sumit.semwal@ti.com>
	<CAAQKjZPFh6666JKc-XJfKYePQ_F0MNF6FkY=zKypWb52VVX3YQ@mail.gmail.com>
	<20120109081030.GA3723@phenom.ffwll.local>
	<CAAQKjZMEsuib18RYE7OvZPUqhKnvrZ8i3+EMuZSXr9KPVygo_Q@mail.gmail.com>
Date: Mon, 9 Jan 2012 09:17:05 -0600
Message-ID: <CAF6AEGsTGOxyTX6Xijvm8UXGjtVTtYg5X5xfJo8D+47o+xU+bA@mail.gmail.com>
Subject: Re: [RFC v2 1/2] dma-buf: Introduce dma buffer sharing mechanism
From: Rob Clark <rob@ti.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: InKi Dae <daeinki@gmail.com>
Cc: Sumit Semwal <sumit.semwal@ti.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, linux@arm.linux.org.uk, arnd@arndb.de, jesse.barker@linaro.org, m.szyprowski@samsung.com, t.stanislaws@samsung.com, Sumit Semwal <sumit.semwal@linaro.org>, daniel@ffwll.ch

On Mon, Jan 9, 2012 at 4:10 AM, InKi Dae <daeinki@gmail.com> wrote:
> note : in case of sharing a buffer between v4l2 and drm driver, the
> memory info would be copied vb2_xx_buf to xx_gem or xx_gem to
> vb2_xx_buf through sg table. in this case, only memory info is used to
> share, not some objects.

which v4l2/vb2 patches are you looking at?  The patches I was using,
vb2 holds a reference to the 'struct dma_buf *' internally, not just
keeping the sg_table

BR,
-R

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
