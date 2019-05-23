Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 324EFC282DE
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 14:01:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFE382184B
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 14:01:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFE382184B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=rowland.harvard.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7693C6B0003; Thu, 23 May 2019 10:01:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 719156B0005; Thu, 23 May 2019 10:01:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 607F56B0006; Thu, 23 May 2019 10:01:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 410D86B0003
	for <linux-mm@kvack.org>; Thu, 23 May 2019 10:01:56 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id q23so5421568qtb.4
        for <linux-mm@kvack.org>; Thu, 23 May 2019 07:01:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:mime-version;
        bh=/bhmPGWxP3kghjmF6VPgun/cBsamkzvrFQQXX1QdOjU=;
        b=Hr4RSuc8QtVgxg9tZoQM2Y1n5LuJiuwoJh0WDI9fDC/Lr/umPCR+YahCGCOkZNUvFf
         J3u/Ij2TKfeH7jCQgqpFxR5xgVmbnZl+bYNSX+NQicTZuSfkR91UWHq1UVgMsu1HRKw/
         9DgETHZAIAMA/CdTAteeEFXsSjapZmXay/XV346m1gEa4ncwhv4UObLdKaJRbHpaCv9E
         npFCIWvqJYLDjuY6d0UrE5KDIa3Di6s8zXlyRNRMcoEkAmVPBoFyrrRtjWwK5qoTs/R/
         4bTAvBOiZ3sX7FTHwUcnBC2yk8q3fW3azQt0hyTg8ak4kgsHK+R3gfUi3YkcjH+Zlhkb
         IOEg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of stern+5cece118@rowland.harvard.edu designates 192.131.102.54 as permitted sender) smtp.mailfrom=stern+5cece118@rowland.harvard.edu
X-Gm-Message-State: APjAAAUjFYcp+KJzFqYp0ckgGEaVX1KZmB8LogFedXZJRU6X7+JsjMkl
	s8veQCBxjHh736/snut7nnDFmjl1RFkYQxQk4L0wrlQbEeMjSqe5iVY/UXNzpEUPW0zMrMtLKh1
	WbwETyQA1ClTjF1hRJGY7x32euxs0TzkpBB7AvCSU7QfBTmhtBuKx0OkQocNrDMPhUA==
X-Received: by 2002:ac8:1672:: with SMTP id x47mr77289454qtk.92.1558620116049;
        Thu, 23 May 2019 07:01:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxFmtAzyx64Bwoi4xx8GnmQmoFnqhAVCTQQZyjwNQPoE8Shhp2W9BaXgLaWO7VmM19Fl48a
X-Received: by 2002:ac8:1672:: with SMTP id x47mr77289373qtk.92.1558620115367;
        Thu, 23 May 2019 07:01:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558620115; cv=none;
        d=google.com; s=arc-20160816;
        b=wEea+1LSeLJqA287NDZiiZfQbhhNHyfOMzPqrZCtzz6LjiMgdHdOmeaUB4yQIF8gqT
         NLyY8NHNNWxi1Z5YSEvvDg7Si+yV4iCJ0+daR8gvwddn0vG7Qc8xyDayKkGUySWlHmoJ
         0FcPi8oEBwOt4cEw2Omk+c8rUvfzEi/x60UIJBZz8gjr/uWVBL5c2ahbf3BNGmod968+
         1s8YuoBsLCLcRbYw5UFNr/9LKf7Todk5CrwRCqzXpuwFBx0JfqiUlQ5Gvbs0jMalj83L
         IUoYhWPJbSb+Ns6UBFIewfqJagL8xMCymL5hbIi2jxKrGYUyHDCWkRF+VX7hKjRsXV9D
         1ugQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:in-reply-to:subject:cc:to:from:date;
        bh=/bhmPGWxP3kghjmF6VPgun/cBsamkzvrFQQXX1QdOjU=;
        b=ITqb+TgWCa9SGC6a5zhj6A9q70J52JkOry13NHhH6JciV5MPMJnT8S8onnrQxwv6gu
         axW/UGrHccQAqFUHDN5lMMiZ2eqZNVCD2zXS00A6SY5pDoa34q9pP2SW3i4/ujybZwte
         Ff0pBr2rxsQxvZjJ+lkQ1UgzQVd6ihbvNdzg2r28Hnd1MpNID0LFo0odV74LC+BF7LP2
         cBYpAadqBy/raiNMDpVALk0oHXibQrhpiAbujx55a+yx7SO6CylpnTUzAFPghFMXhrsW
         KnahGPz1HD/lPEFRtD5AeaajsyVjpnDzZ6FY7NUvnPUW0RaTut39+StrPonxdOxjlg60
         5G5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of stern+5cece118@rowland.harvard.edu designates 192.131.102.54 as permitted sender) smtp.mailfrom=stern+5cece118@rowland.harvard.edu
Received: from iolanthe.rowland.org (iolanthe.rowland.org. [192.131.102.54])
        by mx.google.com with SMTP id b17si8306776qvb.43.2019.05.23.07.01.55
        for <linux-mm@kvack.org>;
        Thu, 23 May 2019 07:01:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of stern+5cece118@rowland.harvard.edu designates 192.131.102.54 as permitted sender) client-ip=192.131.102.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of stern+5cece118@rowland.harvard.edu designates 192.131.102.54 as permitted sender) smtp.mailfrom=stern+5cece118@rowland.harvard.edu
Received: (qmail 1600 invoked by uid 2102); 23 May 2019 10:01:54 -0400
Received: from localhost (sendmail-bs@127.0.0.1)
  by localhost with SMTP; 23 May 2019 10:01:54 -0400
Date: Thu, 23 May 2019 10:01:54 -0400 (EDT)
From: Alan Stern <stern@rowland.harvard.edu>
X-X-Sender: stern@iolanthe.rowland.org
To: Oliver Neukum <oneukum@suse.com>
cc: Jaewon Kim <jaewon31.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, 
     <linux-mm@kvack.org>,  <gregkh@linuxfoundation.org>, 
    Jaewon Kim <jaewon31.kim@samsung.com>,  <m.szyprowski@samsung.com>, 
     <ytk.lee@samsung.com>,  <linux-kernel@vger.kernel.org>, 
     <linux-usb@vger.kernel.org>
Subject: Re: [RFC PATCH] usb: host: xhci: allow __GFP_FS in dma allocation
In-Reply-To: <1558558075.2470.2.camel@suse.com>
Message-ID: <Pine.LNX.4.44L0.1905231001100.1553-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 May 2019, Oliver Neukum wrote:

> On Mi, 2019-05-22 at 10:56 -0400, Alan Stern wrote:
> > On Wed, 22 May 2019, Oliver Neukum wrote:
> > 
> > > I agree with the problem, but I fail to see why this issue would be
> > > specific to USB. Shouldn't this be done in the device core layer?
> > 
> > Only for drivers that are on the block-device writeback path.  The 
> > device core doesn't know which drivers these are.
> 
> Neither does USB know. It is very hard to predict or even tell which
> devices are block device drivers. I think we must assume that
> any device may be affected.

All right.  Would you like to submit a patch?

Alan Stern

