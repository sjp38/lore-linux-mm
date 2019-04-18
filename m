Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0300C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:58:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6761F2183F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:58:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6761F2183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kroah.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 001F76B0005; Thu, 18 Apr 2019 11:58:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF44C6B0006; Thu, 18 Apr 2019 11:58:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE2B76B0007; Thu, 18 Apr 2019 11:58:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A812F6B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 11:58:04 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j1so1652944pff.1
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 08:58:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Ug4OHXueX0nIe1aOLRS1xwsMNImVI2maB8iwKPqB3ko=;
        b=ZGFe3thJLy0C2VzGL26bQtbeQKjIgbS5BaWPQaXgVOB5DONGvxj3cFeG8fedAE7bU7
         KDh4iHsgDdZKFw9/WmiYwyCXrELhVz4KL97lA9QCYC5iLFXCyR/fpOxdaMEteH0iTZak
         gbE4E6DDoy5rTTwcpPJPfbXbtOvKqjBorU9GTrBwmOPyCkOcwic95GGTPGMImGlMbJpY
         LdZqZEcwmswtYPSYIAT020k9a6gfw241mxtGl9AyYFgDowS0vr9W+qSo6owEDEL3ZD9c
         vOXxwN5wS1rb42d5Y4wRzaemAWpuuX+/IdJS3/qlqq65ho9y9yvOzQrOHSzHSZoSezyU
         K/RA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
X-Gm-Message-State: APjAAAXI777gKA9I50OQUSSekF9fqoQTOxfGPdCsAhvhKBC4xxBSVLnH
	IL+fllnBraW3+tuJh6q2IbJeUP03x8RAGpdlSO53u4Jdmsm2k3uB1gXplUAru8UEH9JuXkJpGfD
	mX36Hh0MbSYHqxjOcYIbo9G2yXKEdv1s2Pt/PHL9JGCFE3pnQOFGqAVpD9Q+jcBc=
X-Received: by 2002:a63:7219:: with SMTP id n25mr3927159pgc.258.1555603084350;
        Thu, 18 Apr 2019 08:58:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJWk0oyzxFdhGSfZdzpnxRfgpAhmS9B+5HnYfvY93Swl1NwU8ZxzNw2lq7YUgJjGuNMZxx
X-Received: by 2002:a63:7219:: with SMTP id n25mr3927098pgc.258.1555603083614;
        Thu, 18 Apr 2019 08:58:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555603083; cv=none;
        d=google.com; s=arc-20160816;
        b=WaM3y5xhf5yOxBZapBRLNaTY39r0zo1q+YPT9/ErRHrJ73ZxDE/JAqQYSqchznqI7Z
         V3wXfMRA3uHWAWgQ0VDbhNPR0YtMr/O2jVcwMgqVJXqlh0FDTgyvddCD5JUZQMTwcmJW
         Vtm3ls0CG8ACVTFajbLH7MyIvlieO1JxKUcnHjQa1iW9mfcjjVTme3pEsRJ0LXEk0+F+
         AA/B5FTdkLuMEd3bqEBYZdEcttAPi5ApzNTz725OoM1/xdXiD6zsWoKicptHu70fPdun
         jUjPMZIGkmKQFtojcJ0F7Nhg0y4gxS8VRqcFRGDkLvWARvby3WwCXnoylJqSlI9YcqBe
         cpHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Ug4OHXueX0nIe1aOLRS1xwsMNImVI2maB8iwKPqB3ko=;
        b=NA3RRSUAPV1xhsMX9iKR+6nh6nzJpWVdt7ltB4OWkbmUkSpFYBIOYc0cvWiRoxUpRP
         bmKbaUzm72lX8C2DW26ZCG9wtX+8hvH+TXXdFN+A9p7j0RC8je2DIB8OhxyXd57eW0wq
         uXQ1FQpsPJh2+eCV6B+DgVrwBO4l/uwCtZOxOP3P8Wf2aC2HTMAkZh8j7TS9QeWCEIi+
         GfyeMMauRhQoIRurk7gzCyur1rB7O74bFZDf2h8DZ8TR2XwZ8AXYDZiHdN7FcOk+tZlz
         Nbpc21SA+YThT6frtBlz+TVuiGzF3daMnLp56M0L83UKmA0rmRN1ZIYtkmThxlSTa9ZJ
         kpHg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p15si2570438pff.225.2019.04.18.08.58.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 08:58:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B551220821;
	Thu, 18 Apr 2019 15:58:02 +0000 (UTC)
Date: Thu, 18 Apr 2019 17:58:00 +0200
From: Greg KH <greg@kroah.com>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: stable@vger.kernel.org, linux-mm@kvack.org,
	Roman Gushchin <guro@fb.com>, Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH 4.19.y 1/2] mm: hide incomplete nr_indirectly_reclaimable
 in /proc/zoneinfo
Message-ID: <20190418155800.GA15778@kroah.com>
References: <155482954165.2823.13770062042177591566.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155482954165.2823.13770062042177591566.stgit@buzz>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 09, 2019 at 08:05:41PM +0300, Konstantin Khlebnikov wrote:
> From: Roman Gushchin <guro@fb.com>
> 
> [ commit c29f9010a35604047f96a7e9d6cbabfa36d996d1 from 4.14.y ]
> 
> Yongqin reported that /proc/zoneinfo format is broken in 4.14
> due to commit 7aaf77272358 ("mm: don't show nr_indirectly_reclaimable
> in /proc/vmstat")
> 
> Node 0, zone      DMA
>   per-node stats
>       nr_inactive_anon 403
>       nr_active_anon 89123
>       nr_inactive_file 128887
>       nr_active_file 47377
>       nr_unevictable 2053
>       nr_slab_reclaimable 7510
>       nr_slab_unreclaimable 10775
>       nr_isolated_anon 0
>       nr_isolated_file 0
>       <...>
>       nr_vmscan_write 0
>       nr_vmscan_immediate_reclaim 0
>       nr_dirtied   6022
>       nr_written   5985
>                    74240
>       ^^^^^^^^^^
>   pages free     131656
> 
> The problem is caused by the nr_indirectly_reclaimable counter,
> which is hidden from the /proc/vmstat, but not from the
> /proc/zoneinfo. Let's fix this inconsistency and hide the
> counter from /proc/zoneinfo exactly as from /proc/vmstat.
> 
> BTW, in 4.19+ the counter has been renamed and exported by
> the commit b29940c1abd7 ("mm: rename and change semantics of
> nr_indirectly_reclaimable_bytes"), so there is no such a problem
> anymore.
> 
> Cc: <stable@vger.kernel.org> # 4.19.y
> Fixes: 7aaf77272358 ("mm: don't show nr_indirectly_reclaimable in /proc/vmstat")
> Reported-by: Yongqin Liu <yongqin.liu@linaro.org>
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---
>  mm/vmstat.c |    4 ++++
>  1 file changed, 4 insertions(+)

Both of these now queued up, thanks!

greg k-h

