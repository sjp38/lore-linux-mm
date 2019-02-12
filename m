Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 838B4C282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 20:34:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49F4D222C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 20:34:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49F4D222C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5D878E0002; Tue, 12 Feb 2019 15:34:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0C448E0001; Tue, 12 Feb 2019 15:34:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B48BD8E0002; Tue, 12 Feb 2019 15:34:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 838C28E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 15:34:12 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id l76so53002pfg.1
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 12:34:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=16C3eL5Ef2km9fElYxdCDMJDpLR4cD42eFnKWgSzkro=;
        b=HP5HY3Q/udAM5PlqPny/mWgGGtwQH2TkT3ATPy2OC+d4ircSVdv/rpfRNuFMnoC3tz
         sACBB243hmLzj5Le+g89k46bVJbRLLM5bhqLmX/i2Jf+6q3NepFlPGko4TBVHn5zEpFa
         MLo7IEAmwJTVk3iLUziJzrsnrWhE2cdo3zTeg1UI3cPVCwBT6KkXvrymRZiFmTlD0eFb
         FTtEOUlLjL3I+SST8neful6dp6YOwXO35GCoVXfO+b34lWR2ElaaH55OYB/h4XYSoIf2
         KcqcM93u5PYF58ogYYRjbZiQ9Zbi4ZXK4KPs4r5AMAgallWFu1kuZrPf1QPfg5sUAkx6
         ByLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuaEGxtrpAltf8GgOZUih+AUyu8l3V8xuCgc6noNUYpIL/Ubi87/
	0zP+0jbiLb2WAPzBSrtXTGOMX39LuPseJtDjQ4eghLj8LhM54lwo7GYxr9HdskW2YikbZow/HeS
	yIKhbx0V9d50h3yRlc8cNp9qyVZnLvQapNVpQovsSpaXhEFEN2ptK6z2Y9MH0PFeDQw==
X-Received: by 2002:a63:ea06:: with SMTP id c6mr5353972pgi.162.1550003652136;
        Tue, 12 Feb 2019 12:34:12 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaFBD5oE4MRrwQ3zW33xMWVU6dhNZc4QTemv5ZsERzXJcQ+g0e47h9Ny46/brMEVRBcgZPS
X-Received: by 2002:a63:ea06:: with SMTP id c6mr5353920pgi.162.1550003651246;
        Tue, 12 Feb 2019 12:34:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550003651; cv=none;
        d=google.com; s=arc-20160816;
        b=JYyThHPqk6zMaOHxOsLcIUbP4k8T6UZSmpm9DOETg6s6tulvwXh+EBn/AjqPGpirrf
         u7VIeTC58eu/x9dtrZPrsUV6knFH/rzTVUYCUuqogNMrl0VUO53CglcDf0XxAvo9oahW
         JH3bMzdjnIFF+TmZ+f9NyJXpwzKxQ1bIDRpMCLNaBLfrDXGpO6XvcKFhwEVKHpqeN5YL
         UJBiI6AXMQzhgBL5KUDrh0lVE6pSA0u6KgDqjEjWGsHse6lhzFueyjxH+v2g5zDGHdTU
         eViPJvLq3gmkRDAWajPi0KYgCyz4BhWTBQcPNOS57Tcn6PYhAeI0Vy6fW908BQs2ZOIF
         +Y/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=16C3eL5Ef2km9fElYxdCDMJDpLR4cD42eFnKWgSzkro=;
        b=gbuA87cCGU2Ez6ybhC6bBknd9kbupOF38OjJY0Mkqny5z+M3yacGVdyVHODy3uNnKU
         Q/LPiXPDy1myyBksasxPDqUpIYK/32M2nqC/bOTCMfdpOpRP7XMiYEu4xX3psOZcCDsh
         09W79NLwTjsKc1Pao6qdFPKnRE1Y/5yzbO+uUAjs5TWgyUt84LXauOksuh0DN/wT/3Ru
         iwujnwp7xhhhIj/iSUC9cScQ7g1HfXFKCmtV+OYOCFsgIrlfejkkIRYks+8JWpMpyNuN
         fU/CTXPZCmHDV20hzHZOaBa7KaoxeqMuFQ/rQnaAdmyt4Yv3m188EGAvm2E0y0u+zVBD
         UgCw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h35si4065792pgm.536.2019.02.12.12.34.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 12:34:11 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 72BA5E132;
	Tue, 12 Feb 2019 20:34:10 +0000 (UTC)
Date: Tue, 12 Feb 2019 12:34:09 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Roman Gushchin <guroan@gmail.com>, linux-mm@kvack.org, Matthew Wilcox
 <willy@infradead.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org,
 Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v2 0/3] vmalloc enhancements
Message-Id: <20190212123409.7ed5c34d68466dbd8b7013a3@linux-foundation.org>
In-Reply-To: <20190212184724.GA18339@cmpxchg.org>
References: <20190212175648.28738-1-guro@fb.com>
	<20190212184724.GA18339@cmpxchg.org>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2019 13:47:24 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Tue, Feb 12, 2019 at 09:56:45AM -0800, Roman Gushchin wrote:
> > The patchset contains few changes to the vmalloc code, which are
> > leading to some performance gains and code simplification.
> > 
> > Also, it exports a number of pages, used by vmalloc(),
> > in /proc/meminfo.
> > 
> > Patch (1) removes some redundancy on __vunmap().
> > Patch (2) separates memory allocation and data initialization
> >   in alloc_vmap_area()
> > Patch (3) adds vmalloc counter to /proc/meminfo.
> > 
> > v2->v1:
> >   - rebased on top of current mm tree
> >   - switch from atomic to percpu vmalloc page counter
> 
> I don't understand what prompted this change to percpu counters.
> 
> All writers already write vmap_area_lock and vmap_area_list, so it's
> not really saving much. The for_each_possible_cpu() for /proc/meminfo
> on the other hand is troublesome.

percpu_counters would fit here.  They have probably-unneeded locking
but I expect that will be acceptable.

And they address the issues with for_each_possible_cpu() avoidance, CPU
hotplug and transient negative values.

