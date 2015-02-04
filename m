Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id D77A2828FC
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 19:14:57 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id fb4so28370394wid.2
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 16:14:57 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id k10si31829382wif.41.2015.02.03.16.14.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 16:14:55 -0800 (PST)
Date: Wed, 4 Feb 2015 00:14:39 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [Linaro-mm-sig] [RFCv3 2/2] dma-buf: add helpers for sharing
 attacher constraints with dma-parms
Message-ID: <20150204001439.GB8656@n2100.arm.linux.org.uk>
References: <1422347154-15258-1-git-send-email-sumit.semwal@linaro.org>
 <7233574.nKiRa7HnXU@wuerfel>
 <20150203200435.GX14009@phenom.ffwll.local>
 <3327782.QV7DJfvifL@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3327782.QV7DJfvifL@wuerfel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linaro-mm-sig@lists.linaro.org, Daniel Vetter <daniel@ffwll.ch>, linaro-kernel@lists.linaro.org, Robin Murphy <robin.murphy@arm.com>, LKML <linux-kernel@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rob Clark <robdclark@gmail.com>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>

On Tue, Feb 03, 2015 at 10:42:26PM +0100, Arnd Bergmann wrote:
> Right, if you have a private iommu, there is no problem. The tricky part
> is using a single driver for the system-level translation and the gpu
> private mappings when there is only one type of iommu in the system.

You've got a problem anyway with this approach.  If you look at my
figure 2 and apply it to this scenario, you have two MMUs stacked
on top of each other.  That's something that (afaik) we don't support,
but it's entirely possible that will come along with ARM64.

It may not be nice to have to treat GPUs specially, but I think we
really do need to, and forget the idea that the GPU's IOMMU (as
opposed to a system MMU) should appear in a generic form in DT.

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
