Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6388C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 20:13:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 808CA2183F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 20:13:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 808CA2183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DA546B000D; Thu, 18 Apr 2019 16:13:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 189876B000E; Thu, 18 Apr 2019 16:13:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 078E26B0010; Thu, 18 Apr 2019 16:13:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id C89846B000D
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 16:13:48 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id q18so2083418pll.16
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 13:13:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tXVtThwJI96fZly4Fy3Em+i728w+Fo1hxlDA+b038uk=;
        b=KcliDNE708+S2btZL7GcqMHWr0UqeVx3ruo2WhfpyrTUEKIypnKPdf6sjbUN/Tjpau
         tJxuM+bmYJzFTQug00udzmQX8ErMm9JLO9+ebHOAtIIeQ5y1rMvoqOWWQ0fBnfm7rTUf
         nBiNycY/i6Wp3IufYjeMpBTwtLq6Xn8faf83PjmPaogMjt/gnn8h0i0X8k54RCtVwQRH
         +VoMvCiKckl7rp0fgKthtUc0P+kqfRsfluxQMOETyBq/MWuq6xwvVxP0VTKTeQLW8+HZ
         GtVSXCqkRQ7D3XRa1R4pCcSYl28llpPj5UxQSYJxGq121c4C4PAQJ2+0TkHOER1DXf3x
         3vXw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=+LPG=SU=goodmis.org=rostedt@kernel.org"
X-Gm-Message-State: APjAAAXwu8sj2kLqfAvc5duYB7lOmDa3gh5h1u/RfQ9a4iG0AcMf9CUE
	7ScmAkBV4qWbWZ16TROo/PO5xxPWec7JWQWrXxdCLjsc8HyilfsQD+92kr+8qgkD4oYzWPsU88g
	l4MGxMEhfMp2rrQAVfRe4J6fOJrAvb0t/SOKpFd8LRsI4tHMiemq7uy4MT3Og0xo=
X-Received: by 2002:a63:2405:: with SMTP id k5mr7421571pgk.447.1555618428514;
        Thu, 18 Apr 2019 13:13:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz48AUmV3MvSg+UIUzCqO9sPsWBJ36do4EENqVEd0hDMaLK5xlGmvut0pJ3Wuh29j7hPkdY
X-Received: by 2002:a63:2405:: with SMTP id k5mr7421526pgk.447.1555618427842;
        Thu, 18 Apr 2019 13:13:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555618427; cv=none;
        d=google.com; s=arc-20160816;
        b=fVNE2LeoOM7rEn3+xp5vFnp0OJqYf8TC6zd7s+3cKOLjEhEJrsKk9/LDxhteLJktoM
         VKRe5SLa7kWY0ga9JiNcKcVj5L82+NLsxaBr5zVZjfcA6gb2y3RxNiiInqXZcAL06u9U
         lbmunmtUwfpxb9T7dBtSDucCq37EsOerZWGT0lrPDHpmLLqwhiHy5dH7VA74c7OfIY5H
         32FHvOCK0ONaSxgR6T8UXMN/mmDDzKw9UFGOHkK9/AK3ZRkccJD0DoMmk0tOYkdNu/8T
         05/3Mt8QEy+rNcIeplVKmkBsxP60Z9hWHEN9p0LTO+OyzNI/y3sFjRwXfY4qJR4VrB1X
         S4JQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=tXVtThwJI96fZly4Fy3Em+i728w+Fo1hxlDA+b038uk=;
        b=aYw1dpwiMa1V1aam5QZGYcISZqJoAiZLJyDR+DFi1hjefjGnEXTTgnll53h/z2Hgj2
         7k+0E81/jsl7X+8r77QxKMZF8wBv2Iez5AQfBm9R3NscWMeA8LwdQdV2mOrVbc55ZFYE
         DWFNoHpc+DG77lM0j0P4BtY5J66nprJjf7WxwiRVXTuGvSytTqM2pzLgYeRe+O8rttKC
         /7qdaaOX6+JZb1Drhlh2uzE5DflGniUjzxv8Jg8wLDIMbYzV8KfFZSbw2CTDD/Opk2co
         f1T6UVOjA2AwiQGQ/X9+JyFIoXrWICfmMshDDnfaHjKl9zkvl7JPDy5q3W3+4BmkTwtZ
         kw/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=+LPG=SU=goodmis.org=rostedt@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d9si2988039pls.12.2019.04.18.13.13.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 13:13:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=+LPG=SU=goodmis.org=rostedt@kernel.org"
Received: from gandalf.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 103CF206B6;
	Thu, 18 Apr 2019 20:13:43 +0000 (UTC)
Date: Thu, 18 Apr 2019 16:13:42 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Tom Zanussi <tom.zanussi@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, LKML
 <linux-kernel@vger.kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>,
 x86@kernel.org, Andy Lutomirski <luto@kernel.org>, Alexander Potapenko
 <glider@google.com>, Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morton
 <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>,
 linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Christoph Lameter
 <cl@linux.com>, Catalin Marinas <catalin.marinas@arm.com>, Dmitry Vyukov
 <dvyukov@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>,
 kasan-dev@googlegroups.com, Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Akinobu Mita <akinobu.mita@gmail.com>, iommu@lists.linux-foundation.org,
 Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>, Marek
 Szyprowski <m.szyprowski@samsung.com>, Johannes Thumshirn
 <jthumshirn@suse.de>, David Sterba <dsterba@suse.com>, Chris Mason
 <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>,
 linux-btrfs@vger.kernel.org, dm-devel@redhat.com, Mike Snitzer
 <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>,
 intel-gfx@lists.freedesktop.org, Joonas Lahtinen
 <joonas.lahtinen@linux.intel.com>, Maarten Lankhorst
 <maarten.lankhorst@linux.intel.com>, dri-devel@lists.freedesktop.org, David
 Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>,
 Daniel Vetter <daniel@ffwll.ch>, Rodrigo Vivi <rodrigo.vivi@intel.com>,
 linux-arch@vger.kernel.org
Subject: Re: [patch V2 20/29] tracing: Simplify stacktrace retrieval in
 histograms
Message-ID: <20190418161342.34f4abca@gandalf.local.home>
In-Reply-To: <014a7564d606b249a5e50bef0fedf266977a935b.camel@linux.intel.com>
References: <20190418084119.056416939@linutronix.de>
	<20190418084254.910579307@linutronix.de>
	<20190418094014.7d457f29@gandalf.local.home>
	<014a7564d606b249a5e50bef0fedf266977a935b.camel@linux.intel.com>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Apr 2019 14:58:55 -0500
Tom Zanussi <tom.zanussi@linux.intel.com> wrote:

> > Tom,
> > 
> > Can you review this too?  
> 
> Looks good to me too!
> 
> Acked-by: Tom Zanussi <tom.zanussi@linux.intel.com>
> 

Would you be OK to upgrade this to a Reviewed-by tag?

Thanks!

-- Steve

