Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 10B516B004F
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 09:23:40 -0500 (EST)
Date: Fri, 9 Dec 2011 14:24:05 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [Linaro-mm-sig] [RFC v2 1/2] dma-buf: Introduce dma buffer
 sharing mechanism
Message-ID: <20111209142405.6f371be6@pyramind.ukuu.org.uk>
In-Reply-To: <201112091413.03736.arnd@arndb.de>
References: <1322816252-19955-1-git-send-email-sumit.semwal@ti.com>
	<201112071340.35267.arnd@arndb.de>
	<CAKMK7uFQiiUbkU-7c3Os0d0FJNyLbqS2HLPRLy3LGnOoCXV5Pw@mail.gmail.com>
	<201112091413.03736.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Daniel Vetter <daniel@ffwll.ch>, "Semwal, Sumit" <sumit.semwal@ti.com>, linux@arm.linux.org.uk, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org

> I still don't think that's possible. Please explain how you expect
> to change the semantics of the streaming mapping API to allow multiple
> mappers without having explicit serialization points that are visible
> to all users. For simplicity, let's assume a cache coherent system

I would agree. It's not just about barriers but in many cases where you
have multiple mappings by hardware devices the actual hardware interface
is specific to the devices. Just take a look at the fencing in TTM and
the graphics drivers.

Its not something the low level API can deal with, it requires high level
knowledge.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
