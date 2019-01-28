Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76897C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 21:11:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 396F82148E
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 21:11:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 396F82148E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF8278E0003; Mon, 28 Jan 2019 16:10:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA6728E0001; Mon, 28 Jan 2019 16:10:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBE388E0003; Mon, 28 Jan 2019 16:10:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8AF0A8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:10:59 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id q62so12348385pgq.9
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 13:10:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=RjhiK3lGftfYW3JDm5/nc7Vdk3JXgijqNTf85iJwPXQ=;
        b=axzQPe9mEoYGzOprBv+LO8Qqbi+vk/sU9FWf/VKt916J2HlI8HGER7LtJUpNtKwO7I
         K5w2dVd2NvHN76ayTj+XuoU9zjxyiPB13vv5Oh/El9ywGbBu9Fbig38mwshPRX69WSS5
         reZegbNa8q8O4Uhn3E3n9bcSUvIKUmFHHGOp93dVHImR8ryELdLv+ZxNqbft65JLDnCU
         TIuOC8Q8GvPne0wUV6WFskHmy8F9LsMl/Y3Y0wmqNieQXYHmp/eJ33BgDCSj6hSKNwhY
         uFkJCTsfZHh5lN4Z1Usbm3KkMH7schKYcEgQa5+rsyNrRI+6E1tp9ya+PHSb/x+KXLVK
         s/hA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukf4fQHDWdHb2f5CaIy4MU2rqDSBKrjj+ZXjOdcVi062PEEWU3Zp
	6sOOtt2nIHxqivbjkn5Lw0hxq9ML3QSu6KZ6au+FCVDnv4toeqdgupB0CeL/9Hx8uAzJf2Xac3A
	dTYfbOdZ6ccNTGRPOpLZUJvkuZAzaViFZzl8YTwZR3Lzu556mAP8fAprWOZz8ai3cdA==
X-Received: by 2002:a17:902:934a:: with SMTP id g10mr22266052plp.172.1548709859259;
        Mon, 28 Jan 2019 13:10:59 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7iUBiVO2IfUCyl+LKYdi5rhsU7kkIQMQE41eacb3d11+Za2/vXdqTsP7YKjHsLAQQRBEZ5
X-Received: by 2002:a17:902:934a:: with SMTP id g10mr22266020plp.172.1548709858643;
        Mon, 28 Jan 2019 13:10:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548709858; cv=none;
        d=google.com; s=arc-20160816;
        b=Ne3ie7JUsUtbMS1Kt6aWKEMIDly9hLMHnh73Y6Ak+VxjTYBZXhneiBQFDBVDHUkVtQ
         CO4+VUsa3yPFD795MUtHXOlzO8Yhf0pd6M71KSHFfH2a6UE76jCMJt01NHLzlxe9e7kp
         kIA8E651GOGO4BAmOW/gLw26IclqkNBEsb7nDF0qazENSeyI6NeYDCiJ2AxdfU7H5Ngo
         rhC+wMst0mqYKcf2E398Jh9hus4K3EmF2dOAWbMofko8XsL71HD7TtXzTCMbom3nXzES
         3WOjrarBIp2ugvxmvKueHoWYrlDIcdV9paN7vMK5C12k3ukNKifGosb+9lLFmjS9Hho7
         wZ1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=RjhiK3lGftfYW3JDm5/nc7Vdk3JXgijqNTf85iJwPXQ=;
        b=Hns1e9tOL+hZhJxf9qJvKfAqVOCESHWPNoG8DjtM3uwGzLf6v0ViJNgD5HFH5mz4Ut
         IoS/lIMja/petjKjiSYCh6axS7ghRuKluphuFTsgfSkzbcBCxudcUr279AMM8ZdHtuWJ
         CTYiTJTQS8cMBgXNnrLSVzKBS0ElWxu7bKFKJlR+ltmCw1sHxX4SMyWD9A8YqSIPnjLF
         hEnYIU9Fs277CXHk4A34AzWGK4bZtG4yuKO0SaxgsjPns/dMbT9dtl8jUTEAtOcB3Ecc
         a7f5AIpwQUvD3IzOncbK9L8pp+5yd+vBIZYi7HB8C2mrOevwoysoRCECP1Q8gu1MC2GX
         XeVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e129si33018609pgc.333.2019.01.28.13.10.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 13:10:58 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id E77252863;
	Mon, 28 Jan 2019 21:10:57 +0000 (UTC)
Date: Mon, 28 Jan 2019 13:10:56 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Davidlohr Bueso <dave@stgolabs.net>, dledford@redhat.com, jack@suse.de,
 ira.weiny@intel.com, linux-rdma@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>, Christoph
 Lameter <cl@linux.com>, Jan Kara <jack@suse.cz>, Daniel Jordan
 <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH 1/6] mm: make mm->pinned_vm an atomic64 counter
Message-Id: <20190128131056.101a126f222929318bb2ea83@linux-foundation.org>
In-Reply-To: <20190123183353.GA15768@ziepe.ca>
References: <20190121174220.10583-1-dave@stgolabs.net>
	<20190121174220.10583-2-dave@stgolabs.net>
	<20190123183353.GA15768@ziepe.ca>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 23 Jan 2019 11:33:53 -0700 Jason Gunthorpe <jgg@ziepe.ca> wrote:

> On Mon, Jan 21, 2019 at 09:42:15AM -0800, Davidlohr Bueso wrote:
> > Taking a sleeping lock to _only_ increment a variable is quite the
> > overkill, and pretty much all users do this. Furthermore, some drivers
> > (ie: infiniband and scif) that need pinned semantics can go to quite
> > some trouble to actually delay via workqueue (un)accounting for pinned
> > pages when not possible to acquire it.
> > 
> > By making the counter atomic we no longer need to hold the mmap_sem
> > and can simply some code around it for pinned_vm users. The counter
> > is 64-bit such that we need not worry about overflows such as rdma
> > user input controlled from userspace.
> 
> I see a number of MM people Reviewed-by this so are we good to take
> this in the RDMA tree now?

Please do.

