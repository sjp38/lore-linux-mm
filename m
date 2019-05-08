Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1153FC004C9
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 00:30:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C314B205ED
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 00:30:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="gRIeqvWj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C314B205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DEB56B0003; Tue,  7 May 2019 20:30:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 48E326B0006; Tue,  7 May 2019 20:30:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 356556B0008; Tue,  7 May 2019 20:30:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0D6296B0003
	for <linux-mm@kvack.org>; Tue,  7 May 2019 20:30:28 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id 17so4616991oix.5
        for <linux-mm@kvack.org>; Tue, 07 May 2019 17:30:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=aNugRNfI1NASCVQQotBkfUx3cjwsiA1TzUpe8ibe7ac=;
        b=GpaF3iga94HB5htAIMvEIwoOg6gldeGkzda+sq2fGhs39bTvKFr+Yi6gTccFqnfhcD
         rxBbL3ssj2o7G07aY61bCMXGM7dtMo6411wvlvPV28ieuA6vOLXMLeq2nwqiHX2pcXsv
         kUNT6QZWyvHNKdx6i34RPGSDoa53ywqEfVwmo5BglEPVqMSZwakqvd9exGiYcIRDxkNO
         frd+GV7RlemYcIWCyiuNCX7sTJZvvW0+IQCBBKnXEF/6x03jChEmifwR0O3uBcU4Abc3
         wkhJxoWvw3zupIEpqWXOypA2pH37csJYnVXogLJW4553ztd3o5Ff+iA0Cn7Nxm5ijwZv
         q8WA==
X-Gm-Message-State: APjAAAX+cij1sMGBfLLjhh+z3pLhfyGQS2evWnxwhhJPtNyKo0xp7AG5
	ITW8JIwDdUZYl5z0yuI7twPJa9LLqz5p0U4A4v5Wpjk4rhnYzKYJCQ5T7MjKDnzqSXKaPGGhXHJ
	V9ZPs86G5eAeu6Qle6y47VeQRqi071jyYOHpImMBp5nfm2dKEUUTAeq7zTkAq5ksjwQ==
X-Received: by 2002:aca:5d8a:: with SMTP id r132mr314387oib.152.1557275427715;
        Tue, 07 May 2019 17:30:27 -0700 (PDT)
X-Received: by 2002:aca:5d8a:: with SMTP id r132mr314350oib.152.1557275427176;
        Tue, 07 May 2019 17:30:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557275427; cv=none;
        d=google.com; s=arc-20160816;
        b=acJEa1G5niXz9n9a7nOMOvwT+ULvkCYPWy97IOiIjujb2d5zj4i24xlFUt4xX0hQjh
         Av+JLYD61muN8BZsEplLnWxPZkPLWhiilBwOlXkWXAGWvCvBMhF17De7V75Dvs2fKrQv
         EA3XnRDMg5bKQd6M+Gvnk4VASz8GOW0JpjstrVVLJlJX0s75GnfUTMWsqN2lDQTsLv3+
         W41ITYLqan/QaFrHm+gugo0uXxaShjvGLon3UsbzhBR50TFqcPUQK7MvLw1KIcWjLJrX
         1v9/xWYo8kldAQa7/EKXfoZY3M5ejC9eNPEhIXJko8K9QqNPW8z0zLqomkyeg5h+r2p5
         QPcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=aNugRNfI1NASCVQQotBkfUx3cjwsiA1TzUpe8ibe7ac=;
        b=ZAnv/7gzovhVi96uMoNkEaKjg1EenElG8AWoranVWjlD/3eSmH16uCwR41rfXMJ/02
         9EBbp0AZ3kH3964/zcieRriCjjrqFVVp/sEgNa7D/oEq8XGB4d0gR55WdD7hdhad99Zw
         yogGRsrzllzpSXarzHszVqEVHU44RD1/jBMi4g9INahVUnGMnheS6yq/YkQR+3GpUgxf
         RfxglF2iZDD0aSLCEYi1pROfmW/clyiP8y4/v319IKMCDWtuK8QSRAfjCfW5YBBuNMyb
         guzdh7EddPZfAIr8ktt1nxl8buz9JiUkl6Vd36pLu1iRTXkSsQx4lA7dhsWVW+i1KSrv
         KjDw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=gRIeqvWj;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x10sor6807125ote.142.2019.05.07.17.30.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 17:30:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=gRIeqvWj;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=aNugRNfI1NASCVQQotBkfUx3cjwsiA1TzUpe8ibe7ac=;
        b=gRIeqvWjXvHVuVEemJNJK8AS0nBpMXjQNbmZV9qOtFksOrHCfrqeuX/vrn0nS6wwxy
         kLfpormJ8YBe4ZEF9hNxd/IFXkViwzDXyjJ7SWlHab5fqkWfEG9z/QESkM0GYa14N37c
         lpNEiivZk/k4qPe6YXKCt/Usic/XxFC7BwQxcRPqPZt9yKca0JFbo8LULWWrbneDHmq+
         K8a2yddzszAkKsKQ3kY36HSo7YkWplePB3l48/W53IN9tPwuJM2Yv7wbC95njLsaoego
         6jh4lLkkJ43Um5WDoj3cd+7cCVtFpC4h2yUMlngnDEfXLG3iM/uPEArsgoY53kR9Wc3H
         DUgQ==
X-Google-Smtp-Source: APXvYqwnFUcfnqP6BFgjGKomJPr5yaMMCBD85pEk3++fjkl68hk/raq4PqQ7V3ysBstXCoK7LDo9wO4kaWYzTHhnX6M=
X-Received: by 2002:a9d:5cc1:: with SMTP id r1mr22059155oti.229.1557275426847;
 Tue, 07 May 2019 17:30:26 -0700 (PDT)
MIME-Version: 1.0
References: <20190507183804.5512-1-david@redhat.com> <20190507183804.5512-9-david@redhat.com>
In-Reply-To: <20190507183804.5512-9-david@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 7 May 2019 17:30:15 -0700
Message-ID: <CAPcyv4hzpuApmKHhC6mHnE-RmiZ8Aspiv5wfd+Fs4QmaDsCJVw@mail.gmail.com>
Subject: Re: [PATCH v2 8/8] mm/memory_hotplug: Remove "zone" parameter from sparse_remove_one_section
To: David Hildenbrand <david@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, 
	Linux-sh <linux-sh@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 7, 2019 at 11:39 AM David Hildenbrand <david@redhat.com> wrote:
>
> Unused, and memory unplug path should never care about zones. This is
> the job of memory offlining. ZONE_DEVICE might require special care -
> the caller of arch_remove_memory() should handle this.

The ZONE_DEVICE usage does not require special care so you can drop
that comment. The only place it's used in the subsection patches is to
lookup the node-id, but it turns out that the resulting node-id is
then never used.

With the ZONE_DEVICE mention dropped out of changelog you can add:

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

