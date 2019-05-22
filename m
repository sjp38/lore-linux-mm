Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C63BC282DD
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 14:56:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FE1620879
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 14:56:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FE1620879
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=rowland.harvard.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9E6E6B0007; Wed, 22 May 2019 10:56:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B4F536B0008; Wed, 22 May 2019 10:56:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A644F6B000A; Wed, 22 May 2019 10:56:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 89C3D6B0007
	for <linux-mm@kvack.org>; Wed, 22 May 2019 10:56:03 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id n5so2468125qkf.7
        for <linux-mm@kvack.org>; Wed, 22 May 2019 07:56:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:mime-version;
        bh=6FflCkVaEbFMXuwYX/y1S7Y+v2RMO74l9U1WQIUFgZY=;
        b=laqOc/5ZgQTbIjR3wGZHSsBsM4JZynpvuYxCljEdZk30oxn+n47FN1R6EHPe5RqggU
         g7PLZ+tjGSgBZiHOe+O0xti/PnCNwuaL3Dm6TTdA3sXO/W+DFkgXjsw4twkVQ3AafU6m
         qtR0pstRxyVcinBZJCcgOwJaYLD5FCnI4esSCmxWUh251hfEHQ+Rl5ZVKyGQyM0XRUvE
         wOvLrSj/+Fbv1EEocaamyKgUoiCQzOYdS0I/xMIbG6kgs1VZEdVsK+v+OCuCA2SxnFlR
         q0Flod5iB5A4d93JeVMqZYRd0cHgRncD0hAUckiUAY9MRafn1lHnaF9f+f27xImp+A9Y
         Xqgw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of stern+5cece118@rowland.harvard.edu designates 192.131.102.54 as permitted sender) smtp.mailfrom=stern+5cece118@rowland.harvard.edu
X-Gm-Message-State: APjAAAVKMP8fStaiYf3C6V7f7yJngjZPkHfVYMTwI0Cu3r9ShK6ZR1AW
	ZhMokAulPP6Zs3AgVJZipn9QcwBkhlY7DNi7MT8HbcimQ3e9oeQviCl2lzuD1w5bbN1k28AeUQu
	ZfqpRoZPPrzAH64v8JkjEzMriHbyMeWOzL79Z4VVKRWU0gi9MtEjIlOjWKEn7UrhzZQ==
X-Received: by 2002:ac8:2ac5:: with SMTP id c5mr68956503qta.332.1558536963334;
        Wed, 22 May 2019 07:56:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwUSAX75woDVzaXvVvJ1eaTOqueDJZR6yi/oIGMrU78UJ5EsJlPoL1IC78201bQ23lDjtwr
X-Received: by 2002:ac8:2ac5:: with SMTP id c5mr68956452qta.332.1558536962614;
        Wed, 22 May 2019 07:56:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558536962; cv=none;
        d=google.com; s=arc-20160816;
        b=Ene/WeUsKjc3A0+LrzuDyjQtoKuwDt+Ae2/3CKisSahsv2FhfYCXb2KQT6PxEAPIMC
         tf3e5brZpR74YerRxFgnXc05R99Xm65+b68c3i5GCvMnkvli1A43Ytv53/ogv6i/081i
         N0/oXAO9RJBE9WelnLYox+VPqp8IpEl+DwEtqJgbvSI3gxK2O554L5aYApAhE2Lhx7//
         +wXhBRl67KO13Djy80XGXpjKa5a2B8e0ugzvJ9jwpzF6lOkW4bFHGAigXORj4Nn57PFx
         P5Hn3gKA0n57G1BdHBSw4ue1YWaPg/N1i+7VmjbJA/xkHiMacnsaopjQ7ao3AaS4kpJT
         1cHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:in-reply-to:subject:cc:to:from:date;
        bh=6FflCkVaEbFMXuwYX/y1S7Y+v2RMO74l9U1WQIUFgZY=;
        b=MTJfVnENRHd8G6X6vKn3XMhKG1iyE9YKKLAC9gFlLWZPh1YjNCbfQ1kMLRqiyRgjj6
         nG6dq6sX9HhPgmNXG2waMdTOPgmiWwIoLgRwlJeaXhJIUfon0ConjQZqd/plgD6hfc3U
         bPrnrYxVFfqkVNw4uP8Eb3fSYxY8msF8BKBxFERx/fAtYYqueh/jsJ1sy/EQlkvLrILu
         NcmEhEGvSMIZdFSb1hiLHxSEQOyHIztSVvcNE+mVRacl7e644Pr9dhKgoShbV32leyJR
         5gW9KjtvnZ1njUdL6NRhquKZQ9kzuTU2+FDUVUwQ8fpOsDa/HlsdOYgaehZ6x3I4bhCS
         nVdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of stern+5cece118@rowland.harvard.edu designates 192.131.102.54 as permitted sender) smtp.mailfrom=stern+5cece118@rowland.harvard.edu
Received: from iolanthe.rowland.org (iolanthe.rowland.org. [192.131.102.54])
        by mx.google.com with SMTP id k93si396757qte.13.2019.05.22.07.56.02
        for <linux-mm@kvack.org>;
        Wed, 22 May 2019 07:56:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of stern+5cece118@rowland.harvard.edu designates 192.131.102.54 as permitted sender) client-ip=192.131.102.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of stern+5cece118@rowland.harvard.edu designates 192.131.102.54 as permitted sender) smtp.mailfrom=stern+5cece118@rowland.harvard.edu
Received: (qmail 2691 invoked by uid 2102); 22 May 2019 10:56:01 -0400
Received: from localhost (sendmail-bs@127.0.0.1)
  by localhost with SMTP; 22 May 2019 10:56:01 -0400
Date: Wed, 22 May 2019 10:56:01 -0400 (EDT)
From: Alan Stern <stern@rowland.harvard.edu>
X-X-Sender: stern@iolanthe.rowland.org
To: Oliver Neukum <oneukum@suse.com>
cc: Jaewon Kim <jaewon31.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, 
     <linux-mm@kvack.org>,  <gregkh@linuxfoundation.org>, 
    Jaewon Kim <jaewon31.kim@samsung.com>,  <m.szyprowski@samsung.com>, 
     <ytk.lee@samsung.com>,  <linux-kernel@vger.kernel.org>, 
     <linux-usb@vger.kernel.org>
Subject: Re: [RFC PATCH] usb: host: xhci: allow __GFP_FS in dma allocation
In-Reply-To: <1558506702.12672.28.camel@suse.com>
Message-ID: <Pine.LNX.4.44L0.1905221055190.1410-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 May 2019, Oliver Neukum wrote:

> On Di, 2019-05-21 at 10:00 -0400, Alan Stern wrote:
> > 
> > Changing configurations amounts to much the same as disconnecting,
> > because both operations destroy all the existing interfaces.
> > 
> > Disconnect can arise in two different ways.
> > 
> >         Physical hot-unplug: All I/O operations will fail.
> > 
> >         Rmmod or unbind: I/O operations will succeed.
> > 
> > The second case is probably okay.  The first we can do nothing about.  
> > However, in either case we do need to make sure that memory allocations
> > do not require any writebacks.  This suggests that we need to call
> > memalloc_noio_save() from within usb_unbind_interface().
> 
> I agree with the problem, but I fail to see why this issue would be
> specific to USB. Shouldn't this be done in the device core layer?

Only for drivers that are on the block-device writeback path.  The 
device core doesn't know which drivers these are.

Alan Stern

