Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8ECC4C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 11:58:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C47422CF7
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 11:58:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IbFeySsw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C47422CF7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED5DC6B0007; Tue, 20 Aug 2019 07:58:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E860D6B0008; Tue, 20 Aug 2019 07:58:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D75FD6B000A; Tue, 20 Aug 2019 07:58:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0184.hostedemail.com [216.40.44.184])
	by kanga.kvack.org (Postfix) with ESMTP id BA2B36B0007
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 07:58:58 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 65DC6181AC9C4
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 11:58:58 +0000 (UTC)
X-FDA: 75842659956.06.hook25_31312578ce028
X-HE-Tag: hook25_31312578ce028
X-Filterd-Recvd-Size: 4760
Received: from mail-ed1-f45.google.com (mail-ed1-f45.google.com [209.85.208.45])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 11:58:57 +0000 (UTC)
Received: by mail-ed1-f45.google.com with SMTP id a21so5996182edt.11
        for <linux-mm@kvack.org>; Tue, 20 Aug 2019 04:58:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=/1KOLHuoZmI8qiyc2AOBgmJlzcAvVNP8vz7jHrzKe9k=;
        b=IbFeySswadCdvDM8PjCXQ4bFd7j/LO0lEjdS0yKeFAPgXlCRZ1Z661b7DM2i+EsHFs
         UlwLAol67V1qgoD+FbILiJQoa8U6GJB9UwxG8MXUG93/6r4E1vzda4y+qbM3DzpfQkO4
         WJMoo3sCQbaHwlUklMPLs29gemdfSBtA2tbBKnUlECdxRcSS7y8zg0oqyao1etAycZfv
         /MhTOGyMxLfwTVKDGYU3YecVVCIlUNCoyjTSbOKvxJ9NGW3iSrIPq6k2KBH9aBVzLRc0
         ZbAcfhYyVtIZcMIZ+fajAT2BsQU0jWdSZFQ+lV0xnyr8PCFF9pBZBjw+PMjKfBTu8R5o
         EQ3A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=/1KOLHuoZmI8qiyc2AOBgmJlzcAvVNP8vz7jHrzKe9k=;
        b=YqVTkheSpsxi3CD2mHqpkDkbczB70bnRTmn/FJ7DFkdYZXQAhS57TVQ0V8qznpcH1w
         HXcDWcrC8DQKC83h69hyblY63luNtXWq+v+90JN5zHAgPp51TtR9tIFvLn5HdRV/ZR63
         EjTxflR0EFrXerY7zrWT4nFNAMa6F5P/q6R9ocZqnPHeBVJVukFgRHHHCmUOYA0tPBMh
         mktTWKcezEA1m650DJP+j2wvoGWqZi1H5eZwxm0H+divWfcUvVH8YRonjMy9mVWVMwt6
         yakILgY/7g5hEWzhz4oSqr/vUBsUZ7SsXwcnVSmii5/rRbLOKEblq0GtOy6KfHe9dzcU
         pzyA==
X-Gm-Message-State: APjAAAUVml+w6BUzduXuXFCbV+evYMPS/wD9ogVkxHejUpHjlqsN9Paz
	0uPUla+G2is9HQhEqZlzVamzwwE+57Y1/qX59efi2fKj
X-Google-Smtp-Source: APXvYqzxWMfoc0A4Sat0il4Ewntitxf7D01CxjTHja0EGQkR/iRDfUiKkmY49qAIeqFiTIfXSuAhRszxLz+Hh1kNNd4=
X-Received: by 2002:aa7:d285:: with SMTP id w5mr30213456edq.134.1566302336846;
 Tue, 20 Aug 2019 04:58:56 -0700 (PDT)
MIME-Version: 1.0
References: <CAKSqxP85cbYXt6q72aajXUTombZb-wbEfoWteBQrjJFO890rfg@mail.gmail.com>
 <1566297465.2657.14.camel@HansenPartnership.com>
In-Reply-To: <1566297465.2657.14.camel@HansenPartnership.com>
From: Paul Pawlowski <mrarmdev@gmail.com>
Date: Tue, 20 Aug 2019 13:58:46 +0200
Message-ID: <CAKSqxP-igwDqk0sT5O8T0y9rNVSrakYaNbkLAiof5-NzTtNCbA@mail.gmail.com>
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
Thank you for your reply and sorry for the confusion.

I mean the IOMMU mapping state, not anything regarding the device state.

If I create a DMA mapping before the suspend (as in,
dma_alloc_coherent was called before suspend), and then try to pass
the DMA mapping address to the device after the system is resumed, the
device gives me an error back.
However, if the DMA mapping is created after the suspend is completed,
the device accepts it and processes the data.

In my particular case, the device stores state into a DMA buffer for
suspend. I attempted to persist the DMA buffer mapping through the
suspend however this caused a device error when I tried to tell the
device to restore the state on resume.
If I copied the data from the old buffer into a newly allocated one
(using dma_alloc_coherent), and then tried to use that address, the
device successfully resumed.
The buffer is obviously not freed, at least not in my driver code.

I assume this is not expected and I had to end up with a bug somewhere
in my driver code?

Thank you,
Paul Pawlowski

On Tue, Aug 20, 2019 at 12:37 PM James Bottomley
<James.Bottomley@hansenpartnership.com> wrote:
>
> On Mon, 2019-08-19 at 21:49 +0200, Paul Pawlowski wrote:
> > Hello,
> > Do DMA mappings get cleared when the device is suspended to RAM? A
> > device I'm writing a driver for requires the DMA addresses not to
> > change after a resume and trying to use DMA memory allocated before
> > the suspend causes a device error. Is there a way to persist the
> > mappings through a suspend?
>
> What are you actually asking?  The state of the IOMMU mappings should
> be saved and restored on suspend/resume.  However, whether mappings
> that are inside actual PCI devices are saved and restored depends on
> the actual device.  In general we don't expect them to remember in-
> flight I/O which is why I/O is quiesced before devices are suspended,
> so the device should be inactive and any I/O in the upper layers will
> be mapped on resume.  The DMA addresses of the mailboxes are usually
> saved and restored, but how is up to the driver.
>
> James
>

