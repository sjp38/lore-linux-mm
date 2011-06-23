Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C1965900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 18:09:56 -0400 (EDT)
Received: by gyg13 with SMTP id 13so1154892gyg.14
        for <linux-mm@kvack.org>; Thu, 23 Jun 2011 15:09:55 -0700 (PDT)
MIME-Version: 1.0
Reply-To: M.K.Edwards@gmail.com
In-Reply-To: <BANLkTikzTwNvaaUSk26qzONemogBAGuBRg@mail.gmail.com>
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
	<4E017539.30505@gmail.com>
	<001d01cc30a9$ebe5e460$c3b1ad20$%szyprowski@samsung.com>
	<4E01AD7B.3070806@gmail.com>
	<002701cc30be$ab296cc0$017c4640$%szyprowski@samsung.com>
	<4E02119F.4000901@codeaurora.org>
	<4E033AFF.4020603@gmail.com>
	<BANLkTikzTwNvaaUSk26qzONemogBAGuBRg@mail.gmail.com>
Date: Thu, 23 Jun 2011 15:09:55 -0700
Message-ID: <BANLkTimi2FAmcb7ZWnjRqb-Cb8acXWsCTw@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCH/RFC 0/8] ARM: DMA-mapping framework redesign
From: "Michael K. Edwards" <m.k.edwards@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Morton <jonathan.morton@movial.com>
Cc: Subash Patel <subashrp@gmail.com>, Jordan Crouse <jcrouse@codeaurora.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-arch@vger.kernel.org, linaro-mm-sig@lists.linaro.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

Jonathan -

I'm inviting you to this conversation (and to linaro-mm-sig, if you'd
care to participate!), because I'd really like your commentary on what
it takes to make write-combining fully effective on various ARMv7
implementations.

The current threads:
  http://lists.linaro.org/pipermail/linaro-mm-sig/2011-June/000334.html
  http://lists.linaro.org/pipermail/linaro-mm-sig/2011-June/000263.html

Archive link for a related discussion:
  http://lists.linaro.org/pipermail/linaro-mm-sig/2011-April/000003.html

Getting full write-combining performance on Intel architectures
involves a somewhat delicate dance:
  http://software.intel.com/en-us/articles/copying-accelerated-video-decode-frame-buffers/

And I expect something similar to be necessary in order to avoid the
read-modify-write penalty for write-combining buffers on ARMv7.  (NEON
store-multiple operations can fill an entire 64-byte entry in the
victim buffer in one opcode; I don't know whether this is enough to
stop the L3 memory system from reading the data before clobbering it.)

Cheers,
- Michael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
