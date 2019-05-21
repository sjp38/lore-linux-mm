Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A0B6C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 14:00:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0356F21479
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 14:00:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0356F21479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=rowland.harvard.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6649D6B0003; Tue, 21 May 2019 10:00:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6150A6B0006; Tue, 21 May 2019 10:00:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 529DB6B0008; Tue, 21 May 2019 10:00:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 312BC6B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 10:00:12 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id l185so10738841qkd.14
        for <linux-mm@kvack.org>; Tue, 21 May 2019 07:00:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:mime-version;
        bh=fnDAJf2ya1MMBX7glzPZ25P8Fu5IoQyt4BQ1lJ1VaMw=;
        b=J2Zq1rPTHTpkKybFhAvq06l31qJZ0VVIBmomzD32UCAK/bCb04urENcqjZXlyVWWvW
         dbm5phm3TlBD65txd9XwgRbFVLiUlRWVv+zOA8bZEATGiAPB4GlDmouAivs8B4HqJYdo
         R8LjkBnFzx+yUJEHIRxSxXuZ5bZHZadAMHJdLvzfuyV8q9kVCmAmmU4vrwxYpkiFr19j
         BQZ/PjfvR1EZXo6dgKTKUAToJlYwyiXRcfm4/z3NEmv+Jh1zqPW4mzWEcTzqm8wfFESl
         MnPFgqCewPx/Y3SJ2iToRRjVLhD3JmkSfzOKrJsSlqCNduSPK491QjRlEMSocyp4fu02
         wdeg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of stern+5cece118@rowland.harvard.edu designates 192.131.102.54 as permitted sender) smtp.mailfrom=stern+5cece118@rowland.harvard.edu
X-Gm-Message-State: APjAAAU46SXMpfGq1lyEGz0ZDBlqwFt8naPPazdwR8FzJ4+Fqg03eVoZ
	4B0wrDOjS2CTIFDGAYCN5mtdY/QwiHzhEe2cmzdLqWrOInHaY4nk919psRuYs0/RMXQ5bk6M7He
	3cY9iaCjZTcpl77L2iePp7FkWUlqfu4IQxgEd1fej/EhRcKZOd1Os6tA5pYsZ1Z86cg==
X-Received: by 2002:a37:af03:: with SMTP id y3mr4513590qke.296.1558447211898;
        Tue, 21 May 2019 07:00:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxxQJIUJ8tGGCKNiaayJejdLH4e/EuYZaFnZr5IygkkRRFPfWG8so2vQ4nlf7bV7We7MUbe
X-Received: by 2002:a37:af03:: with SMTP id y3mr4513508qke.296.1558447211178;
        Tue, 21 May 2019 07:00:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558447211; cv=none;
        d=google.com; s=arc-20160816;
        b=wDNU7a+EkbgCCva9KmC3HE2e3RzK8bLr57T3nXLdbZd1e2P4ECq+EUCEcw2hJgvbxL
         TUnHJbYOIcLXtAMgZjrZSOiQQk/jjH0FBFlKYWrrm8iL1dJQWTkj0rLioVr1P8PWwbHq
         s+QrlOSYPvP7O4XdyLvCF3pPT8m1A2y0+94O7ZhfbODG/K56rv1rXCNWjiUNuuR2hQ9D
         jI+EtK7ER4GCn2vSMt5VmJAo7mgcPlPYrxie9bBPInWyZH37W+PQcileCC1Pop2M2l2Y
         XaHtXz0jWEJhejODIyJFWZ0sX6oavuiTN0k69rTPeFmPYZmnks+YulX9C32lxDWqDQi4
         cM1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:in-reply-to:subject:cc:to:from:date;
        bh=fnDAJf2ya1MMBX7glzPZ25P8Fu5IoQyt4BQ1lJ1VaMw=;
        b=m4V5TepJ7Vc5oaRUGhjvFFWqLMGV4ZJHIBh/L79Lkc5aZeXyPHBvDYa41Xbdgi++vH
         /YFXK6T+KrzuHUWlSz0jOyCLtrttP8JFArCKAE4iezsOwBHt+ZVI7r9q8dNBtJmuvccZ
         cmeUVAOzSwAAtgswDLdWLzeLIUklK5OIQmGvtMZb/dx4MscDX3kEZMbHU8aiH7sH7AbA
         4De8oi1dr+jtuyOc0E4nAdjU2iWnCQIpdGEICKkq5rZcq4HmllmQRUjs99xUl7JV2BuZ
         W2EE+SsP5RjGePZxnNYX/P+zebE6RUPRWaEJYYYJCruYOdPwyrHsiAoOX6LJkzGqR9O4
         TZwg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of stern+5cece118@rowland.harvard.edu designates 192.131.102.54 as permitted sender) smtp.mailfrom=stern+5cece118@rowland.harvard.edu
Received: from iolanthe.rowland.org (iolanthe.rowland.org. [192.131.102.54])
        by mx.google.com with SMTP id r2si2574140qtn.276.2019.05.21.07.00.10
        for <linux-mm@kvack.org>;
        Tue, 21 May 2019 07:00:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of stern+5cece118@rowland.harvard.edu designates 192.131.102.54 as permitted sender) client-ip=192.131.102.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of stern+5cece118@rowland.harvard.edu designates 192.131.102.54 as permitted sender) smtp.mailfrom=stern+5cece118@rowland.harvard.edu
Received: (qmail 1871 invoked by uid 2102); 21 May 2019 10:00:10 -0400
Received: from localhost (sendmail-bs@127.0.0.1)
  by localhost with SMTP; 21 May 2019 10:00:10 -0400
Date: Tue, 21 May 2019 10:00:10 -0400 (EDT)
From: Alan Stern <stern@rowland.harvard.edu>
X-X-Sender: stern@iolanthe.rowland.org
To: Oliver Neukum <oneukum@suse.com>
cc: Christoph Hellwig <hch@infradead.org>, Jaewon Kim <jaewon31.kim@gmail.com>, 
     <linux-mm@kvack.org>,  <gregkh@linuxfoundation.org>, 
    Jaewon Kim <jaewon31.kim@samsung.com>,  <m.szyprowski@samsung.com>, 
     <ytk.lee@samsung.com>,  <linux-kernel@vger.kernel.org>, 
     <linux-usb@vger.kernel.org>
Subject: Re: [RFC PATCH] usb: host: xhci: allow __GFP_FS in dma allocation
In-Reply-To: <1558444291.12672.23.camel@suse.com>
Message-ID: <Pine.LNX.4.44L0.1905210950170.1634-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 May 2019, Oliver Neukum wrote:

> On Mo, 2019-05-20 at 10:16 -0400, Alan Stern wrote:
> > On Mon, 20 May 2019, Christoph Hellwig wrote:
> > 
> > > GFP_KERNEL if you can block, GFP_ATOMIC if you can't for a good reason,
> > > that is the allocation is from irq context or under a spinlock.  If you
> > > think you have a case where you think you don't want to block, but it
> > > is not because of the above reasons we need to have a chat about the
> > > details.
> > 
> > What if the allocation requires the kernel to swap some old pages out 
> > to the backing store, but the backing store is on the device that the 
> > driver is managing?  The swap can't take place until the current I/O 
> > operation is complete (assuming the driver can handle only one I/O 
> > operation at a time), and the current operation can't complete until 
> > the old pages are swapped out.  Result: deadlock.
> > 
> > Isn't that the whole reason for using GFP_NOIO in the first place?
> 
> Hi,
> 
> lookig at this it seems to me that we are in danger of a deadlock
> 
> - during reset - devices cannot do IO while being reset
> 	covered by the USB layer in usb_reset_device
> - resume & restore - devices cannot do IO while suspended
> 	covered by driver core in rpm_callback
> - disconnect - a disconnected device cannot do IO
> 	is this a theoretical case or should I do something to
> 	the driver core?
> 
> How about changing configurations on USB?

Changing configurations amounts to much the same as disconnecting,
because both operations destroy all the existing interfaces.

Disconnect can arise in two different ways.

	Physical hot-unplug: All I/O operations will fail.

	Rmmod or unbind: I/O operations will succeed.

The second case is probably okay.  The first we can do nothing about.  
However, in either case we do need to make sure that memory allocations
do not require any writebacks.  This suggests that we need to call
memalloc_noio_save() from within usb_unbind_interface().

Alan Stern

