Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FF38C282CC
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 17:52:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDF61217F9
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 17:52:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDF61217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 86A208E00D9; Wed,  6 Feb 2019 12:52:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F1C38E00D1; Wed,  6 Feb 2019 12:52:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 694408E00D9; Wed,  6 Feb 2019 12:52:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 396FB8E00D1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 12:52:05 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id b187so7147845qkf.3
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 09:52:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=7/P7mL00Gsglud9/osHxxnh+h3PbbceXpT84a+hjR8M=;
        b=tDUUxaqZsPlZe6eajAXbYv5B8F9iGikOL8wUOfIgaMpxgiMR+tsWPpbzEfeA9osBIx
         35sQF7gVssGuaWsbT2ynaWHIpAeKWncTd4tlKAVOXY/lijbLmESy3LV42co0G+3HCwpa
         YYqurkFPzouTrAw1UFV6/xTU6C08WHYXM/qtATeuTyhkwkqahOGyc+C7UvSZLTZ3wCZX
         gdoLd4irbNorpc7NVoNUUuuIptoxAKH7h6ShrX5MR1sEFCLLMxQbeAIV7JX4efwIPzn8
         fJVjTyb4kIAYpR2lyxZvIOcNcvWMo3mDCxB84drQW68BbQsviB1eN9PGdQiEHRlnOcMn
         43tg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZDGqBJ68TA9YUl1PzjPLFYFj5D5r6r6j29gTwgAn1y9wMmlRdR
	AAy+2imFOf+CutdIuNAWtIML4oxRwXYVjW07a7ulKsD3d0NDbO5InrO4bG0iVD5v7WaMP6pPbWf
	K+gXVIWgfMztRw+sXgAoBXcAhTtxJwV6eRpdbZmSSA1H8gp+cok9HcLKnPHcbH3B7yA==
X-Received: by 2002:ac8:6053:: with SMTP id k19mr4786750qtm.339.1549475524848;
        Wed, 06 Feb 2019 09:52:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibxf+CHnfMqWz23R+kc7V/UuoZiUEShlusuJvesFZWlnFb8/6vvsFqCIZacN69R0W22oIC5
X-Received: by 2002:ac8:6053:: with SMTP id k19mr4786725qtm.339.1549475524269;
        Wed, 06 Feb 2019 09:52:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549475524; cv=none;
        d=google.com; s=arc-20160816;
        b=vPs3lcK3RHZrqYIDiPgUKDauHLoUlUoW5f/wQZxJd0MYS+ELnu1DWPb6bUoAYrkHK8
         TqGohLhbAycJ9bqOYxk7oBUklr/2MqfJ37bTxlfiUtsoSYxxe7XKTB8jkOCP8VvvIlMA
         FbzI46kvT5RPSFpnDgk67UbgqMTbt1zmIh/8hjkuZQ717oQnsfVSVSRakrf0WLmGLq5I
         u7mYUOKzQ2YqNQBFJcsMV66NHSE9mmA5XkUCnvDD1tX4bUL+LGSHl9vo+t4Y5eygVItD
         4XciKgeq1FWxvK2v8fSWNRw6vyekJblQUKIzf5HkdppdGLxl78r3qTqNLNLdQyzhs4Nl
         Pf4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=7/P7mL00Gsglud9/osHxxnh+h3PbbceXpT84a+hjR8M=;
        b=dxEooiaK4UwRUtJmtFGmEuZTZEaNerSeyrAkJoBR+3xMNIfb5nqYEThSxwdCynY9fq
         fi+ZUy9cL4F4vCh/u8H0QzwpQplRTWte6nj98NbdAkyu1JnXt+Y41IliggliLe+gFb1q
         bC5++zRr5aljZ62kOqnuBLwTirh5/lgCWqcZhl1keoZ1DVIyUYX17iBsgIm23s78lkIq
         FFEV9Wo4EmJ7tTLG8f189n5tOyii6pOnqfWdpKtVBy/vyLr7lx9oyhTwlG096jOduhi8
         Aao6kPIj26q0cZWHmv9jPbLmgjKI2O2bSvUVzZffDu+x9WSM8k5q8xHqpZmJs+EQ+xdt
         tzjw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z54si84443qth.152.2019.02.06.09.52.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 09:52:04 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5D6C1C01DE1B;
	Wed,  6 Feb 2019 17:52:03 +0000 (UTC)
Received: from redhat.com (ovpn-122-237.rdu2.redhat.com [10.10.122.237])
	by smtp.corp.redhat.com (Postfix) with SMTP id A4D0D1048128;
	Wed,  6 Feb 2019 17:52:00 +0000 (UTC)
Date: Wed, 6 Feb 2019 12:52:00 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Nadav Amit <namit@vmware.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org,
	Julien Freche <jfreche@vmware.com>,
	Jason Wang <jasowang@redhat.com>, linux-mm@kvack.org,
	virtualization@lists.linux-foundation.org
Subject: Re: [PATCH 0/6] vmw_balloon: 64-bit limit support, compaction,
 shrinker
Message-ID: <20190206124926-mutt-send-email-mst@kernel.org>
References: <20190206051336.2425-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190206051336.2425-1-namit@vmware.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Wed, 06 Feb 2019 17:52:03 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 05, 2019 at 09:13:30PM -0800, Nadav Amit wrote:
> Various enhancements for VMware balloon, some of which are remainder
> from a previous patch-set.
> 
> Patch 1: Aumps the version number, following recent changes
> Patch 2: Adds support for 64-bit memory limit
> Patches 3-4: Support for compaction
> Patch 5: Support for memory shrinker - disabled by default
> Patch 6: Split refused pages to improve performance
> 
> Since the 3rd patch requires Michael Tsirkin ack, which has not arrived
> in the last couple of times the patch was sent, please consider applying
> patches 1-2 for 5.1.
> 
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: Jason Wang <jasowang@redhat.com>
> Cc: linux-mm@kvack.org
> Cc: virtualization@lists.linux-foundation.org


I don't seem to have got anything except patch 0 either directly
or through virtualization@lists.linux-foundation.org
Could you bounce the relevant patches there?

Thanks!

> Nadav Amit (5):
>   vmw_balloon: bump version number
>   mm/balloon_compaction: list interfaces
>   vmw_balloon: compaction support
>   vmw_balloon: add memory shrinker
>   vmw_balloon: split refused pages
> 
> Xavier Deguillard (1):
>   vmw_balloon: support 64-bit memory limit
> 
>  drivers/misc/Kconfig               |   1 +
>  drivers/misc/vmw_balloon.c         | 511 ++++++++++++++++++++++++++---
>  include/linux/balloon_compaction.h |   4 +
>  mm/balloon_compaction.c            | 139 +++++---
>  4 files changed, 566 insertions(+), 89 deletions(-)
> 
> -- 
> 2.17.1

