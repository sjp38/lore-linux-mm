Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 194A2C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 15:58:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDEE322CF7
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 15:58:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JFUH7EWZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDEE322CF7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E5A16B0006; Tue, 20 Aug 2019 11:58:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 595CD6B0007; Tue, 20 Aug 2019 11:58:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4AC186B0008; Tue, 20 Aug 2019 11:58:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0106.hostedemail.com [216.40.44.106])
	by kanga.kvack.org (Postfix) with ESMTP id 28BB06B0006
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 11:58:42 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id BDF6A181AC9CB
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 15:58:41 +0000 (UTC)
X-FDA: 75843264042.09.crow50_68f2ea3178341
X-HE-Tag: crow50_68f2ea3178341
X-Filterd-Recvd-Size: 5333
Received: from mail-ed1-f68.google.com (mail-ed1-f68.google.com [209.85.208.68])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 15:58:41 +0000 (UTC)
Received: by mail-ed1-f68.google.com with SMTP id h8so6900034edv.7
        for <linux-mm@kvack.org>; Tue, 20 Aug 2019 08:58:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=8BniG56fTvxTf+qITg7pA2OoNjdfhXPZe8EQI2iG588=;
        b=JFUH7EWZHRdrniEgN7l2BQV5vsermZ9NIeXJrD/fUwqnZKh7RGDjXrRNm+AWUkHJrm
         oi7umOTl+1+nXWDIe+dANBO0eh0Dfl3RSoJcclY1he5A1T2fqMXU3FRLij8SS+R/4L1Q
         yP5m5gi+jUAXvJIBTtqdEAun+Gkkm7vPxJ3Lnfjq1em/4xJBIL5cifmOwpuBGSTaUTnI
         uYAHw2ed4jD8tUNIgu5m49sUnY0Uk75ltsakEjGEZdt5B3kAiKO02c0cB12OLUC8yNj8
         KKkkOIQtQl2hX+xBhrV3ck+EVWmrCpzbSABdRtcNYOoX0NTLzR8OU5utqASzwsvyndoa
         kUqQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=8BniG56fTvxTf+qITg7pA2OoNjdfhXPZe8EQI2iG588=;
        b=E4Ig9ffRdY8gXcoWT5flTV+Mtb9NEJr0ba9UiIc80BCwVOfkaI/sqeXqa/Lg1mcL8F
         rueN5GXSS+lkb5NvqkAi86huoGYgI55v9roK3qrjp4qwhIGI1AkDFnajdBG1ODQGw0Zq
         STmjIx/M+UBFIQdiPtPXPR5ZILPXqY20CEWkQs2KA+cTHkQJb0k2GTVRWs7yuKBPM0cc
         7j2GyjF6MIdRyXQgcp2VgmXKSIIVaeKqfRzL8JGfJ6FHZwK8jJ0n4b26+QK07jRZfmf0
         FPXqpom401T9AFvs8Xn4vbFerF64XQDD8rrvzcukKGs4F9VJXDqq/PkOegZeWjJZan3j
         u7xg==
X-Gm-Message-State: APjAAAV20Neg1OolmgKDICSFp/tGPc5egJiK0o0z0G2o/2/64lKWk2Xt
	c0sekFoVqopsdyY52qa0TKwYlnZTc9o4ZRouK1Cyjw==
X-Google-Smtp-Source: APXvYqwurxp+nksbrQnuF9MTwyPIUls98DbWR/eHTGIVxHTscbLPa/01y/3sNgCKb+C7sklqnjqpUftJmEq7+Rh87ig=
X-Received: by 2002:a17:906:e2d9:: with SMTP id gr25mr18919910ejb.94.1566316719959;
 Tue, 20 Aug 2019 08:58:39 -0700 (PDT)
MIME-Version: 1.0
References: <CAKSqxP85cbYXt6q72aajXUTombZb-wbEfoWteBQrjJFO890rfg@mail.gmail.com>
 <1566297465.2657.14.camel@HansenPartnership.com> <CAKSqxP-igwDqk0sT5O8T0y9rNVSrakYaNbkLAiof5-NzTtNCbA@mail.gmail.com>
In-Reply-To: <CAKSqxP-igwDqk0sT5O8T0y9rNVSrakYaNbkLAiof5-NzTtNCbA@mail.gmail.com>
From: Paul Pawlowski <mrarmdev@gmail.com>
Date: Tue, 20 Aug 2019 17:58:29 +0200
Message-ID: <CAKSqxP8rb9e3-VcNnf=nXt5REqs_0NBCKFH4pBgwRx==aM7cDw@mail.gmail.com>
Subject: Re: Do DMA mappings get cleared on suspend?
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

I have done some more debugging now and it turned out that the bug was
indeed in my driver, and that the dma_alloc_coherent()+memcpy()
somehow magically caused the issue not to happen, however it had
nothing to do with the issue.

Sorry for the inconvenience.

Thank you,
Paul Pawlowski


On Tue, Aug 20, 2019 at 1:58 PM Paul Pawlowski <mrarmdev@gmail.com> wrote:
>
> Hello,
> Thank you for your reply and sorry for the confusion.
>
> I mean the IOMMU mapping state, not anything regarding the device state.
>
> If I create a DMA mapping before the suspend (as in,
> dma_alloc_coherent was called before suspend), and then try to pass
> the DMA mapping address to the device after the system is resumed, the
> device gives me an error back.
> However, if the DMA mapping is created after the suspend is completed,
> the device accepts it and processes the data.
>
> In my particular case, the device stores state into a DMA buffer for
> suspend. I attempted to persist the DMA buffer mapping through the
> suspend however this caused a device error when I tried to tell the
> device to restore the state on resume.
> If I copied the data from the old buffer into a newly allocated one
> (using dma_alloc_coherent), and then tried to use that address, the
> device successfully resumed.
> The buffer is obviously not freed, at least not in my driver code.
>
> I assume this is not expected and I had to end up with a bug somewhere
> in my driver code?
>
> Thank you,
> Paul Pawlowski
>
> On Tue, Aug 20, 2019 at 12:37 PM James Bottomley
> <James.Bottomley@hansenpartnership.com> wrote:
> >
> > On Mon, 2019-08-19 at 21:49 +0200, Paul Pawlowski wrote:
> > > Hello,
> > > Do DMA mappings get cleared when the device is suspended to RAM? A
> > > device I'm writing a driver for requires the DMA addresses not to
> > > change after a resume and trying to use DMA memory allocated before
> > > the suspend causes a device error. Is there a way to persist the
> > > mappings through a suspend?
> >
> > What are you actually asking?  The state of the IOMMU mappings should
> > be saved and restored on suspend/resume.  However, whether mappings
> > that are inside actual PCI devices are saved and restored depends on
> > the actual device.  In general we don't expect them to remember in-
> > flight I/O which is why I/O is quiesced before devices are suspended,
> > so the device should be inactive and any I/O in the upper layers will
> > be mapped on resume.  The DMA addresses of the mailboxes are usually
> > saved and restored, but how is up to the driver.
> >
> > James
> >

