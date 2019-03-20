Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BE64C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 19:12:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5CFF32175B
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 19:12:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5CFF32175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2CE86B0006; Wed, 20 Mar 2019 15:12:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED9916B0007; Wed, 20 Mar 2019 15:12:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEFCB6B0008; Wed, 20 Mar 2019 15:12:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C16476B0006
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 15:12:12 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 18so3547409pgx.11
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 12:12:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=20H/scAtpGgvlthV3GTo8dwpoU8jHV62n7FssLM8lOI=;
        b=VEHzJIfhtKEmaCdqDg6eZf0hJkD0b/7DHTeXnPAD5+B1aKZOXOd0UK+Pu1eaN+VNMn
         sTl0EhROaB6CTxrAS0ohiyVyTby+QhQkihooD9yarBGWaEA/ejMKg44hso3UYS56L/g+
         7x+MsMpKnZgYe4mpsDqE9/O6kH9ETQ4bMrSGORq7f7GhVjP/WhRQEzfZs2IWo3CDeIRX
         6rG9XzRg+Pc/NQ3Rs+f5MKQvOeXFO4+S7fvgAoeNCJWcsG9h8QRj2jL/d5nPI9IirNda
         ViBXBWP/FSBldz2tgu8E7GKKtebwfacY9QuVEKw7+AivEVj3tZX9i69AqKgPE/rmj7yX
         U2Iw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAX87D+GtgzrHO9eS8woEX2mgsyPOq5KigZ/cc/N11HhhILDOlME
	3PhgQ39RlxmLhEOoDCcFuN6aMRl769foMGcB5JxZ6Gam0NxTtjHTKtCmIXkAuvjZw4xL/oq+27b
	N0xIaIYXIjuBTPnRkn8WVxKE7ktvKYYH1DHi6U+5StnFfx/j9S26s4hbMhc+qipsk5Q==
X-Received: by 2002:a63:cc0c:: with SMTP id x12mr6297956pgf.336.1553109132305;
        Wed, 20 Mar 2019 12:12:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxiAubJZGR8j9IqDNt6a7ZOuW41H8PNWvmEwA9YKLMRzBttCSPyGeW5iOBYbcK41svwsH9X
X-Received: by 2002:a63:cc0c:: with SMTP id x12mr6297899pgf.336.1553109131433;
        Wed, 20 Mar 2019 12:12:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553109131; cv=none;
        d=google.com; s=arc-20160816;
        b=IAnmz8ijAMzxDi79RXHfV1aBj5dIZ7fhNIXUQz4NEX6hYybh8mWNirFxy1ZEx6gofi
         MOnAcQEk+Do81jlhA1q4NxnEwBmahhVnteqIwm7T0iWfw2Jo5YTP1dm8/UWE4/9xdu2G
         UqpHhpMnPgAj0+jEnH6TyCKOz9ughHrTE5KdSFonT/mT36p0HAHY/Lxv/ZRap8Vr+5eZ
         3Sdsk+C3WFJzmACiBw1yzZCiNLm8RIQ0hx5+9pEcWHh0x3rTgfzjiZRAdtnDaZbmgmEq
         xG3r+hQAY5lBTJ1JsyPChfCWfy9DLbYZUYxmMROJO37O2sRV/5LpTIDg62uFR+RRcpyJ
         mqmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=20H/scAtpGgvlthV3GTo8dwpoU8jHV62n7FssLM8lOI=;
        b=QiEU+M/Xu7j4NyJx1RGvzLJsVEHK0Ex7F3/0y5UeD2Df2Uz3O8OrUaWUUGCdGRSy69
         P4gEuAN+xj1jik0L0ZwPWPaf6IPnkzCw7lJkLW/u2ml7wv68EO+bp2j16xqRXDudcWFN
         DQRZPldEri43IJZbDxVN0XgnHt+3Odqv1/ID3xfvdwKQ5mURJF1rhbEmmiF/prwpxA9t
         gGOJjlMvjy/d+ruLCxwiBw5yH5JLB5r+KHYNNRl2ni8zICecKRlfQImHEyuhrf4yppaK
         LOhpqGg+LXySCeqIu6hCFXTTN4GNu0mndJ25Lio1M0VtYfQtOa51dtPaXh1n80dV3rmC
         oLsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m15si2213632pgv.212.2019.03.20.12.12.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 12:12:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id D9CB24CA1;
	Wed, 20 Mar 2019 19:12:10 +0000 (UTC)
Date: Wed, 20 Mar 2019 12:12:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, osalvador@suse.de, mhocko@suse.com,
 david@redhat.com, richard.weiyang@gmail.com, rppt@linux.ibm.com,
 linux-mm@kvack.org
Subject: Re: [PATCH] mm, memory_hotplug: Fix the wrong usage of
 N_HIGH_MEMORY
Message-Id: <20190320121209.5cd30d7b15f299df7d97d51e@linux-foundation.org>
In-Reply-To: <20190320080732.14933-1-bhe@redhat.com>
References: <20190320080732.14933-1-bhe@redhat.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 20 Mar 2019 16:07:32 +0800 Baoquan He <bhe@redhat.com> wrote:

> In function node_states_check_changes_online(), N_HIGH_MEMORY is used
> to substitute ZONE_HIGHMEM directly. This is not right. N_HIGH_MEMORY
> always has value '3' if CONFIG_HIGHMEM=y, while ZONE_HIGHMEM's value
> is not. It depends on whether CONFIG_ZONE_DMA/CONFIG_ZONE_DMA32 are
> enabled. Obviously it's not true for CONFIG_ZONE_DMA32 on 32bit system,
> and CONFIG_ZONE_DMA is also optional.
> 
> Replace it with ZONE_HIGHMEM.
> 
> Fixes: 8efe33f40f3e ("mm/memory_hotplug.c: simplify node_states_check_changes_online")

What are the runtime effects of this change?

> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -712,7 +712,7 @@ static void node_states_check_changes_online(unsigned long nr_pages,
>  	if (zone_idx(zone) <= ZONE_NORMAL && !node_state(nid, N_NORMAL_MEMORY))
>  		arg->status_change_nid_normal = nid;
>  #ifdef CONFIG_HIGHMEM
> -	if (zone_idx(zone) <= N_HIGH_MEMORY && !node_state(nid, N_HIGH_MEMORY))
> +	if (zone_idx(zone) <= ZONE_HIGHMEM && !node_state(nid, N_HIGH_MEMORY))
>  		arg->status_change_nid_high = nid;
>  #endif
>  }

