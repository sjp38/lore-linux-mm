Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C959C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 14:25:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 17B5420645
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 14:25:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17B5420645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=rowland.harvard.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8AE0B6B0276; Tue, 28 May 2019 10:25:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85E6E6B0279; Tue, 28 May 2019 10:25:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 74D856B027A; Tue, 28 May 2019 10:25:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 605A76B0276
	for <linux-mm@kvack.org>; Tue, 28 May 2019 10:25:14 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id f25so27858193qkk.22
        for <linux-mm@kvack.org>; Tue, 28 May 2019 07:25:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:mime-version;
        bh=ZKZTqXkEbN74CEM7lcdriB5nB3XD4Wz5u4BVx/rL364=;
        b=oNCmSNezNfg13ymKuGcgVZ3TK8XIRmFwWIcoiafBhLbQERotR8d7viY92Tsktiasp/
         npb8p1K0Zd51Mgfk7CuWCPd82/S8Abmg6MfGcsxXdYZBBNwl96UOcKc+cZbA/W3CcHCG
         RGBqdCUEwexwHEZ4n2Kl4b63ntJnXsD7EhwAw10Qzz1Lc26UMwG3ARJwS4eV8wVtR8Wo
         RsoMyYfJxK+mXbhjX6u88MD67L8wC6PocUN94SbxgFrL5stHtM9d0UhsHJmaWvJo89Dc
         GQGimTfQ042TwxcfXtfneJ6HaAdJnDu3Qng9dh5nxNWad35AffPW6T8Y/w1ouU3N8JP9
         fyww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of stern+5cece118@rowland.harvard.edu designates 192.131.102.54 as permitted sender) smtp.mailfrom=stern+5cece118@rowland.harvard.edu
X-Gm-Message-State: APjAAAXVvm/MmGdebcd0+Tf4h0AJQpcDKrB9TJSPMdO6lW4o8vT8kn47
	BtnIpgSccOt4Jow4tCwhk7mBGm66GJ2yK03asaZvsqxWIeYRBr1t1Zcy20DVsSnhiqrT425ZqpL
	/OyKaPqHVAQzpBADdhP+mSD4YDe2ttNK/hXyNxSZ1y2ekW1xG5cr9E5eExlAiAInnTA==
X-Received: by 2002:a05:620a:14ba:: with SMTP id x26mr5995860qkj.328.1559053514161;
        Tue, 28 May 2019 07:25:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqycHo9JoZDeBGi+RzMiDNdLdv/VNi5ftja4q0a3ZLrmFlRXy9Ah4HYrgeHM4uDtQ0O0GaXj
X-Received: by 2002:a05:620a:14ba:: with SMTP id x26mr5995823qkj.328.1559053513383;
        Tue, 28 May 2019 07:25:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559053513; cv=none;
        d=google.com; s=arc-20160816;
        b=i+rRyrkX+cZvczqyK0jy12FLNpA8CTxKpcs2+M3k/u1wP2Me1uaDfwjulmgiA2HDQy
         ll6VluJv4EjkEPxstIzDLNi+VtQyPkn5X+c7Q7rFa49kPz472lotMeki8YqlEPHiHEmO
         W5nzDJpF916doHy8zuKhRvpadUvx+c1NG96cJLWTqn65u6+l9cIVBFMd8aHKUdYHQART
         BJPXKQDWOoZpCCG0Mcmr+nd4aRoMNRleCcxFWTtmHGAL8PGShKgUjIiX1wRR0nAc8Uo4
         6dYje+eHM//AA57I+BdLdWoWqqtCMfyV1ojCPbLOn0Aa5dMfo3HMCJZdzTceJg+oRLGf
         wFnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:in-reply-to:subject:cc:to:from:date;
        bh=ZKZTqXkEbN74CEM7lcdriB5nB3XD4Wz5u4BVx/rL364=;
        b=s3i5I40Yk2rhY4WvPuG+4oEhRNoadWb8uahBT0M0Jak4wPwUJlCmjofsilcCCQHVpF
         D+58guRs56OCFp1lH21EXZY51NHBT1OSUackJAlIkPa4Sksd4zPA2ypvHs4hOXWCkPkD
         3NaMOirACMSKf2/EDe0DPPrJ1w7imUrjkYFPVP6c6lJSKzN4/GyAF2NsB7UrgSszBVZ/
         d+2+IpskG/JCNKjuX2iSDgtqQWTYmbwxSQUGVQIFZlkP5gBIuGQxadb/bgRJNp/VBFUj
         qgIYlr2XWL24GIf7g4SSsLMGLOTpMADKPtpLt18vpL2tRejoxdJF0En0LN1KnZBJcYNk
         gNng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of stern+5cece118@rowland.harvard.edu designates 192.131.102.54 as permitted sender) smtp.mailfrom=stern+5cece118@rowland.harvard.edu
Received: from iolanthe.rowland.org (iolanthe.rowland.org. [192.131.102.54])
        by mx.google.com with SMTP id a8si15284uaf.153.2019.05.28.07.25.13
        for <linux-mm@kvack.org>;
        Tue, 28 May 2019 07:25:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of stern+5cece118@rowland.harvard.edu designates 192.131.102.54 as permitted sender) client-ip=192.131.102.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of stern+5cece118@rowland.harvard.edu designates 192.131.102.54 as permitted sender) smtp.mailfrom=stern+5cece118@rowland.harvard.edu
Received: (qmail 1867 invoked by uid 2102); 28 May 2019 10:25:12 -0400
Received: from localhost (sendmail-bs@127.0.0.1)
  by localhost with SMTP; 28 May 2019 10:25:12 -0400
Date: Tue, 28 May 2019 10:25:12 -0400 (EDT)
From: Alan Stern <stern@rowland.harvard.edu>
X-X-Sender: stern@iolanthe.rowland.org
To: Oliver Neukum <oneukum@suse.com>
cc: Jaewon Kim <jaewon31.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, 
     <linux-mm@kvack.org>,  <gregkh@linuxfoundation.org>, 
    Jaewon Kim <jaewon31.kim@samsung.com>,  <m.szyprowski@samsung.com>, 
     <ytk.lee@samsung.com>,  <linux-kernel@vger.kernel.org>, 
     <linux-usb@vger.kernel.org>
Subject: Re: [RFC PATCH] usb: host: xhci: allow __GFP_FS in dma allocation
In-Reply-To: <1559046886.13873.2.camel@suse.com>
Message-ID: <Pine.LNX.4.44L0.1905281021120.1564-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 May 2019, Oliver Neukum wrote:

> Am Donnerstag, den 23.05.2019, 10:01 -0400 schrieb Alan Stern:
> > On Wed, 22 May 2019, Oliver Neukum wrote:
> > 
> > > On Mi, 2019-05-22 at 10:56 -0400, Alan Stern wrote:
> > > > On Wed, 22 May 2019, Oliver Neukum wrote:
> > > > 
> > > > > I agree with the problem, but I fail to see why this issue would be
> > > > > specific to USB. Shouldn't this be done in the device core layer?
> > > > 
> > > > Only for drivers that are on the block-device writeback path.  The 
> > > > device core doesn't know which drivers these are.
> > > 
> > > Neither does USB know. It is very hard to predict or even tell which
> > > devices are block device drivers. I think we must assume that
> > > any device may be affected.
> > 
> > All right.  Would you like to submit a patch?
> 
> Do you like this one?

Hmmm.  I might be inclined to move the start of the I/O-protected
region a little earlier.  For example, the first
blocking_notifier_call_chain() might result in some memory allocations.

The end is okay; once bus_remove_device() has returned the driver will 
be completely unbound, so there shouldn't be any pending I/O through 
the device.

Alan Stern

