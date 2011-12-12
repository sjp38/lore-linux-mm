Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id AAA106B01A0
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 11:48:57 -0500 (EST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Linaro-mm-sig] [RFC v2 1/2] dma-buf: Introduce dma buffer sharing mechanism
Date: Mon, 12 Dec 2011 16:48:51 +0000
References: <1322816252-19955-1-git-send-email-sumit.semwal@ti.com> <20111209142405.6f371be6@pyramind.ukuu.org.uk> <CAKMK7uH+4uSYYjBLcvfhVC+iwGUZ09Z4p64fNBzh196aG+hqgg@mail.gmail.com>
In-Reply-To: <CAKMK7uH+4uSYYjBLcvfhVC+iwGUZ09Z4p64fNBzh196aG+hqgg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201112121648.52126.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "Semwal, Sumit" <sumit.semwal@ti.com>, linux@arm.linux.org.uk, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Saturday 10 December 2011, Daniel Vetter wrote:
> If userspace (through some driver calls)
> tries to do stupid things, it'll just get garbage. See
> Message-ID: <CAKMK7uHeXYn-v_8cmpLNWsFY14KtmuRZy8YRKR5Xst2-2WdFSQ@mail.gmail.com>
> for my reasons why it think this is the right way to go forward. So in
> essence I'm really interested in the reasons why you want the kernel
> to enforce this (or I'm completely missing what's the contentious
> issue here).

This has nothing to do with user space mappings. Whatever user space does,
you get garbage if you don't invalidate cache lines that were introduced
through speculative prefetching before you access cache lines that were
DMA'd from a device.

	Arnd


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
