Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87DE5C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:18:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FBCC2229F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:18:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FBCC2229F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EAAD18E0141; Mon, 11 Feb 2019 14:18:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E343F8E0134; Mon, 11 Feb 2019 14:18:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD8938E0141; Mon, 11 Feb 2019 14:18:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 999448E0134
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:18:48 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id q21so9889pfi.17
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:18:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1GpebXGE5BdcchC7oLDPlYXoF28+AQgUazhWh0ZYjVc=;
        b=p44xPcKXB6+kAIs3/Ny++2A/XEEkG9JhmeYNzrf6NeiLhNqYo9xb7KFSwWWcy1Zosu
         asKNTawC0JdGqiXQTucDmRlGZLfSkUPT7j/x2Khzld6uLsr/9Tua5QG9voq/kQ1kJZL6
         ZfrqCHJbo7xctzdBhQrcmm7c+Mamto9nlW1flgGtpjD3IRwVL4+XDZeMG/slxHAV5joQ
         r92CAKl+oYv15M1xHYDcLt9Ki5PM5Wf1xiy2H0lMNNHHozOOIUeWUh29cRlJxqKNgb7R
         QGyNTKCqivmSyeZDtVjTll0LhKNBNsGLcjl20JoLf+u5c2eIggSFiBpA0BnLvVgVLKfU
         gqLw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAubYzYZaajyFhfQiczWFSKHbw1uFyOSTUEUPIO0bVSY21AFxIyPm
	j1lDWXGE7UBEoghiJmuf0b/GknPkTZmoowlsuxk1nOLBIY0Ef2wlWMBEotAYI7xnK3pHcNmqNe9
	cswzbzlOCBP/cjW7QoYUPr2ryzfa8aQYMHzSuBCG+Hm+2y0C1bgZUnkWfb1xDBojDOw==
X-Received: by 2002:a63:da14:: with SMTP id c20mr33640307pgh.233.1549912728326;
        Mon, 11 Feb 2019 11:18:48 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaLuRnVSfR1zq8v8zIknmx7kWsqFs2BLbKpRrtEatfxUAF5a8NYqRyEGnULhWnZQB8WP0HX
X-Received: by 2002:a63:da14:: with SMTP id c20mr33640251pgh.233.1549912727638;
        Mon, 11 Feb 2019 11:18:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549912727; cv=none;
        d=google.com; s=arc-20160816;
        b=key7gYaO5Jc7DSebtvmVffvrfsF/VcoUdkfhA8F4j6sESIrvu8zAOsK8Iz6qqvcTIO
         pHxjLSSlkgh/2yD4pBqiLCGM0rPzi0MjBU48cz5vrL4m0IyTGJoLG0WsFyyaqbWk8Bye
         b90g5Tq/b3GsweXv8zYEgwCMESS+KmjOObCTy16UI7g5PEJvFKOFQUwVv8/A3b8lW1cN
         qOPIrQMozntimKBcLGiP5tGVw0frHjYyRx/MjAIrUppevNM2glbl9AGUZ3x4uz6Z1Af1
         kV4DF3ZiAuc7t8RY3s7bUeU96BqypKsBaGbgN/adXvkHIAOrduqsGj/RgA7flvG/RgMz
         QmCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=1GpebXGE5BdcchC7oLDPlYXoF28+AQgUazhWh0ZYjVc=;
        b=x+f9aewx4pQQrwqX1z7WOsHwq6yjODalvyMYWf69y0GABPx9fkm+OCzekEstprJVDh
         LvhdkcmL63nRkrFteruUgjVjQQd+D7vDY2fdml6l4STkbu4ldSx494Hc1m234JHioheM
         K2Ag1PiXKRqaM62YpQIiObB+iTqFjppQG2P2zkxXglwgCOedxaOjXpglQLgDgiShdHa8
         K77SWO00A5YyNYVO0mXCEULf6S7dMdg6VFML0HpQM8k2qB2vf8hGVlrRidp1YSMkqcpo
         h8n/3Jozs1jnVuIiltp39Wo7rUDl1VjDo78hcdML5ywnWHWBzxlvlOOsJ/svFiZpRRhg
         bbQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id az12si10645115plb.78.2019.02.11.11.18.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 11:18:47 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 21496D6DD;
	Mon, 11 Feb 2019 19:18:47 +0000 (UTC)
Date: Mon, 11 Feb 2019 11:18:45 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Roman Gushchin <guroan@gmail.com>, linux-mm@kvack.org, Matthew Wilcox
 <willy@infradead.org>, Michal Hocko <mhocko@suse.com>,
 linux-kernel@vger.kernel.org, kernel-team@fb.com, Roman Gushchin
 <guro@fb.com>
Subject: Re: [PATCH 0/3] vmalloc enhancements
Message-Id: <20190211111845.fcc4210d35020a721149da74@linux-foundation.org>
In-Reply-To: <20190211190822.GA14443@cmpxchg.org>
References: <20181219173751.28056-1-guro@fb.com>
	<20190211190822.GA14443@cmpxchg.org>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Feb 2019 14:08:22 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Wed, Dec 19, 2018 at 09:37:48AM -0800, Roman Gushchin wrote:
> > The patchset contains few changes to the vmalloc code, which are
> > leading to some performance gains and code simplification.
> > 
> > Also, it exports a number of pages, used by vmalloc(),
> > in /proc/meminfo.
>
> These slipped through the cracks. +CC Andrew directly.
> Andrew, if it's not too late yet, could you consider them for 5.1?
> 

There's been some activity in vmalloc.c lately and these have
bitrotted.  They'll need a redo, please.

