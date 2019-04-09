Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20AE0C282DE
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 13:08:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBB8520855
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 13:08:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBB8520855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CD816B0008; Tue,  9 Apr 2019 09:08:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77DBE6B000D; Tue,  9 Apr 2019 09:08:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 645D26B000E; Tue,  9 Apr 2019 09:08:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 304266B0008
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 09:08:02 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id s6so772567edr.21
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 06:08:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=PswzQ2aW5SrNl7OVEPd2WzPDPU0VgDCaQWosqiH4MPM=;
        b=PF9+WLqVbq/PKhvxg4l6lEtQSqfahbn8Ic153Kh1e/W+NMdsUQudNzW+xOQ32uADfb
         AFY9Ufrp7EwxI23Aqx1Odb9KA6vjg9eyyf/SUqyV+O8xsC5n+JTe9yk/u2VMxuEK9niQ
         yx2lyRtqMNNUpIow8YzuAA7bfsqbliXv+JurZF4R5a+KYhYms8iMOmZqADnnGoj34A6j
         Et8jfj0KA/Y9xloVQL+2BDrVupUjf7vqOxqMQa2oKrGGgNkwrOiCLkZoH3/Nr54HaUt9
         6nzmBfeILA5Ql81UavpAwa7JfcoBNYwhxbrTqYhBGQ0WoGexe/EThzROQZufJVhaqcDx
         yIpg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAXAGbeQeUEt3sjaNljcGQk/tgHoLki9EMPD5VuAUEc2jJIvEPBF
	Q1o7UDGnUS3+Q+T8S5RHOrD67Y1Q7tQTdxP0jsoIb96s3BrHMr1sPpxUksY+oCaOrR1fWUJUxGa
	sri7wUKzP+Z22i+uY1bbyDPSNewZ1EqSsmnb5VzMoGCHSBxIDwcvxMflJEYD3uygeUg==
X-Received: by 2002:a17:906:31cf:: with SMTP id f15mr20024070ejf.246.1554815281728;
        Tue, 09 Apr 2019 06:08:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxf56J78KIF5ep9BhdZwxOOZwnOA6Yl/7LiZSY6g8kSE6nqH2CAwOvfiEdl62gZ0X2enOIG
X-Received: by 2002:a17:906:31cf:: with SMTP id f15mr20024033ejf.246.1554815280928;
        Tue, 09 Apr 2019 06:08:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554815280; cv=none;
        d=google.com; s=arc-20160816;
        b=erV6kLHEew/wUrt+D2spjTJaCa+W3MiZw7ilhtF9ff+ap8gm5qQ4LkHDQ/ZH5CknCC
         +kHsDmAdI4kFFZQW1+Wl+TGosOtS81LHVyowKdM7ZMinO/RfV0Uwuf+Gy2YlLnS6+sgZ
         bSOzbNfYk59dImwMabZ2+L4RdgkxP3S1b6hgLxdQX8+riLoGoCc6Ikq1gVnx2LGw0rGG
         UJxGlla/ePGFMwqNRS0U6STV2HmGmNCv12NdpAAtDKqD4v/I96AZ3hTGLo2C/jeQf52Z
         cx1Dr/XnOVT8yxtfbL9sl5lI/UMp1W2em5hMbCLbMNbDcuGOlElVgTIxKax7/Q/WKg71
         mdQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=PswzQ2aW5SrNl7OVEPd2WzPDPU0VgDCaQWosqiH4MPM=;
        b=VXbyIf0RNNSJXJB4R4HsVHf7GbEVBBx/XxuDZudhnGCbR5x3KWc/58u6/NtBpVLUDr
         PgFMNYtez1c9jeFGOdnhDgp7NEJPMQ/qMVi1VnTpKZQ6IdtfsIX2qpC0DqrHhhc8AfGO
         cNeb/ZptLCWNyhN6oXP52Bt3kFxJM8da34bnNpSkKwbr20yEB/qKEnGUJC4aEPydUQjf
         a1YHcrkpxEckYwnA2xzcEccR5MPn7eto345/fH90vylPjRE0/MvXQ/VTY97o46cGHVce
         2II6yuvfzdCR7te/sFcDmjTsOpUmJJLIAqwRSMRSWdiFzfJhnQOlhykoq0bzQlWDi174
         XRHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s17si3542752edx.387.2019.04.09.06.08.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 06:08:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 09070ACC1;
	Tue,  9 Apr 2019 13:08:00 +0000 (UTC)
Subject: Re: [PATCH v5 0/7] mm: Use slab_list list_head instead of lru
To: "Tobin C. Harding" <tobin@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: Roman Gushchin <guro@fb.com>, Christoph Lameter <cl@linux.com>,
 Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>, Matthew Wilcox <willy@infradead.org>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190402230545.2929-1-tobin@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a4950b5e-1af8-4ce6-8b01-ea9c9caa45d0@suse.cz>
Date: Tue, 9 Apr 2019 15:07:58 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190402230545.2929-1-tobin@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/3/19 1:05 AM, Tobin C. Harding wrote:
> Tobin C. Harding (7):
>   list: Add function list_rotate_to_front()
>   slob: Respect list_head abstraction layer
>   slob: Use slab_list instead of lru
>   slub: Add comments to endif pre-processor macros
>   slub: Use slab_list instead of lru
>   slab: Use slab_list instead of lru
>   mm: Remove stale comment from page struct

For the whole series:

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> 
>  include/linux/list.h     | 18 ++++++++++++
>  include/linux/mm_types.h |  2 +-
>  mm/slab.c                | 49 ++++++++++++++++----------------
>  mm/slob.c                | 59 +++++++++++++++++++++++++++------------
>  mm/slub.c                | 60 ++++++++++++++++++++--------------------
>  5 files changed, 115 insertions(+), 73 deletions(-)
> 

