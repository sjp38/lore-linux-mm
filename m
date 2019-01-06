Return-Path: <SRS0=q3d4=PO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E54CC43612
	for <linux-mm@archiver.kernel.org>; Sun,  6 Jan 2019 21:46:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A5E9213A2
	for <linux-mm@archiver.kernel.org>; Sun,  6 Jan 2019 21:46:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="M/bEAEry"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A5E9213A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 82E368E0003; Sun,  6 Jan 2019 16:46:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B3508E0001; Sun,  6 Jan 2019 16:46:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A3488E0003; Sun,  6 Jan 2019 16:46:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id F187A8E0001
	for <linux-mm@kvack.org>; Sun,  6 Jan 2019 16:46:57 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id e12-v6so10834431ljb.18
        for <linux-mm@kvack.org>; Sun, 06 Jan 2019 13:46:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Nn7oD0ol2iP0y2yprlx6IYbrc5ZCwYkBInEfjdZxW1Q=;
        b=lZ/rJhqJZ//P1vswWkImLXwpv3hIcgJBgzQzq59l/9eGHqW2+Ap/xK6nELH9jtapWU
         zA3hHJYzx97FEKkcg2/yLhSAHnTjF9iYsW7dXfx9qJiNsf5JX+7WllmmkEOeRyvHB4rM
         a++v1FPkJ0wOgfTr5G3L9xBO+CXOk2FDFHmWroU4/NrV569eMYw7YfsWfgfWYtn1eNWD
         uIkU4Tz06aK9Xwnb8HBNc9Bbr80tgR7HrMl80P09v9yWIj/sSLvS5PWu+QasLi47RRZv
         9eOrpxb/dJ1r3OvulXmcg6j9UDOH2jGCcp3wI348MtHhPQGFpAFsvr73ehbpF9Pgccwl
         bBBQ==
X-Gm-Message-State: AA+aEWYVPVMvltir/+YJgPSKjD4MAnwhuSQ5khNaIV8EYjsFEKW2xahH
	V93EyQxoYhiOfDALs1rH6iNJWIKVh1t0pXzBo/tYLhnP+bCkbb65omwnnU3X9gFpu69PpCuvpX/
	XnGvglgzmCFzaeQhAo/SZbaF44y1ANy6YbFp9qF8NyegIej2r92+kFgQ85951ZyO6uLqxRkvkMm
	cQSWr2mj3HSPKaoITgx3ssjJ2tZe/gvT6gfoZKVQJgL0REtP0aKGcUHfEd+cELG0LIdXPMj2D0p
	ER29sfHQytrUkTvhn0JigF6urPRSHg6P+4hysdiX5730CIdKgnyB+nOxu2XSSOlaO7ikb8elued
	SfLOPpoRTxFeaX3bjL8btddHk3c9DHSdrXnx3MkPRnle9AQlvfiFDCVlWZqadJrTEzOHYoLX1aU
	4
X-Received: by 2002:a19:2b54:: with SMTP id r81mr31135585lfr.34.1546811217222;
        Sun, 06 Jan 2019 13:46:57 -0800 (PST)
X-Received: by 2002:a19:2b54:: with SMTP id r81mr31135568lfr.34.1546811216113;
        Sun, 06 Jan 2019 13:46:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546811216; cv=none;
        d=google.com; s=arc-20160816;
        b=mgm+QRkojaILe39LfiUhbdk2fd9mwKx3jnaw9JfnetWNcUA0sWdNW4LfPaybDzAjHO
         qrTsYcXic+YVSNyrCPDgC0Gi6pY7ZCV1XSK+ZpYUIGAEjX7LmnWqcG1a+IEXMh0SCkDk
         87QLO7VC8V31CZBYq7vo6e2JPAB7vxIfJHqCAcS3BhVtg2jGyQhx3nglX+EhikB0Bf3b
         nlCvQolZWf4dZeLhHVsYyJUnNDCQQy/3XQmg+aR3tS9sjnTDLHHmYHE6BCRYfyxqW4u1
         fQt6w69HZtlEHh9bVLDN0KCXHk/XGZ6O6654/21V6ui1oiWsMblvHZn4WpqoQMdeSi2f
         aLvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Nn7oD0ol2iP0y2yprlx6IYbrc5ZCwYkBInEfjdZxW1Q=;
        b=BZA4s9Cqh8EMZuylKn4XDxQJSLkGlbtPlVweG8F3YDbduBW9ySylz7uy9LWAMwJXvM
         zgtZSjAEHJ5cDhX1uQQDHKKyNtpJRXYVdtAh/b9HsEWnkAKNpycr/UVDzU4HMQZDYvnz
         /6utubcp9GLAdlu3uwwqBCGWWJ9B5TT+egbC9uf3fJW2Y96bdobd5wXQrcJl7zY0cJ4X
         3tvXr1Z9pDqazcw2IUYRCl9/QnfijI3k9gBnskRnDet5wdEn+Yc1Irx9WPQOJqYoN/Tk
         7fEyC9Y0JXnrZ8ZrE3qTwqkTFAez3e5FYLT5zvReI29d7lece8byUKnF15nYceM/ZJKw
         5V3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b="M/bEAEry";
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u10sor15902865lfu.33.2019.01.06.13.46.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 06 Jan 2019 13:46:55 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b="M/bEAEry";
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Nn7oD0ol2iP0y2yprlx6IYbrc5ZCwYkBInEfjdZxW1Q=;
        b=M/bEAErya4WRSn1yBbBGino0mk0VL3ARKUKSUTjPHagjtYO0zZ0S6MvcT7J5V2CWp6
         bOL3Jrs2fvoni9kUHg4lOokcHUJ6H5QMa6syqJfEW0w/haX0AYMs8KJlqwsGEDtCkz6u
         nXNYcC+GPtGSdTNy5xuCQTCKFgzJZ+nNo6Yy4=
X-Google-Smtp-Source: ALg8bN6AKIdxxxgI0la6ezgO+5mw0aaL4LSfAZX/LEwcLCnAcvWp1faN3jS6FP+sk7HTJ69674/Eew==
X-Received: by 2002:a19:4948:: with SMTP id l8mr8647390lfj.156.1546811215126;
        Sun, 06 Jan 2019 13:46:55 -0800 (PST)
Received: from mail-lj1-f180.google.com (mail-lj1-f180.google.com. [209.85.208.180])
        by smtp.gmail.com with ESMTPSA id m10-v6sm13590778ljj.34.2019.01.06.13.46.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Jan 2019 13:46:53 -0800 (PST)
Received: by mail-lj1-f180.google.com with SMTP id k15-v6so36511962ljc.8
        for <linux-mm@kvack.org>; Sun, 06 Jan 2019 13:46:53 -0800 (PST)
X-Received: by 2002:a2e:95c6:: with SMTP id y6-v6mr11741960ljh.59.1546811213226;
 Sun, 06 Jan 2019 13:46:53 -0800 (PST)
MIME-Version: 1.0
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <CAG48ez2jAp9xkPXQmVXm0PqNrFGscg9BufQRem2UD8FGX-YzPw@mail.gmail.com>
 <CAHk-=whL4sZiM=JcdQAYQvHm7h7xEtVUh+gYGYhoSk4vi38tXg@mail.gmail.com>
 <CAHk-=wg5Kk+r36=jcGBaLUj+gjopjgiW5eyvkdMqvn0jFkD_iQ@mail.gmail.com>
 <CAHk-=wiMQeCEKESWTmm15x79NjEjNwFvjZ=9XenxY7yH8zqa7A@mail.gmail.com>
 <20190106001138.GW6310@bombadil.infradead.org> <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com>
 <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com>
In-Reply-To: <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 6 Jan 2019 13:46:37 -0800
X-Gmail-Original-Message-ID: <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com>
Message-ID:
 <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Matthew Wilcox <willy@infradead.org>
Cc: Jann Horn <jannh@google.com>, Jiri Kosina <jikos@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, 
	Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190106214637.WKjqV6rP1AeareyYWgF0z2KbdrUaahzyDcpNP9BzCyg@z>

On Sat, Jan 5, 2019 at 5:50 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Slightly updated patch in case somebody wants to try things out.

I decided to just apply that patch. It is *not* marked for stable,
very intentionally, because I expect that we will need to wait and see
if there are issues with it, and whether we might have to do something
entirely different (more like the traditional behavior with some extra
"only for owner" logic).

But doing a test patch during the merge window (which is about to
close) sounds like the right thing to do.

                 Linus

