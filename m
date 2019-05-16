Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BAB4FC04AAF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 22:53:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A4B02082E
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 22:53:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="PFxJAbUY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A4B02082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B95156B0005; Thu, 16 May 2019 18:53:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B449E6B0006; Thu, 16 May 2019 18:53:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A5BC86B0007; Thu, 16 May 2019 18:53:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 477736B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 18:53:25 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id 134so978555lfk.23
        for <linux-mm@kvack.org>; Thu, 16 May 2019 15:53:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=YtKHs6p1hkPZRuLpWntFvRSIJdzjPy+3GlRYlCY9zeo=;
        b=WISfXK/nhFXhm04WpvrqTCcwCzNRofjXpenPh6z0o9EbClbJDY6y/hrIRurR5xXUgl
         sq5R07lZkszugYitUQu0QqFt/VRFXRkEbh1jBSNNwYHYWGOvMzD8hu2fpPFAWwSuMYBk
         V7gcM4ghWQ3zSUWuAlMwONsceWzmj0+cJKX0oHtOeSeDNivfgFAZizgf8FQgc4Vu6Drr
         RAZ7FlgNVrQ+tN004uICYH9ygLWm9XrDvrtblS0uLptdV72UDCKMEEzLdZBvmL/n3yZl
         WVtcfJsDfiwRCWyUbFKZtsHpUFfcngO+5P253ZePgbzPypgH5FiHhy5VNP2mOrixrC4f
         kfEA==
X-Gm-Message-State: APjAAAWeQeAW5mTcIQwPnFssQIf2KXaVwdC0bz1zJD+HmDJkeO1qXtTk
	DX77wcGiLgT9uQti0ci7oAE+GNnHRe+JTVQ3/MKWlb779mF/HWKUWnV2f3DGuYCLBNEV/TEpD89
	iDQBJueua3d++BQTUmVhpP4MQfiy0Rgojfm4ORgduSzK62XQN6X3DxpHAOe9AJ1CfSA==
X-Received: by 2002:ac2:424b:: with SMTP id m11mr11523434lfl.71.1558047204478;
        Thu, 16 May 2019 15:53:24 -0700 (PDT)
X-Received: by 2002:ac2:424b:: with SMTP id m11mr11523408lfl.71.1558047203144;
        Thu, 16 May 2019 15:53:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558047203; cv=none;
        d=google.com; s=arc-20160816;
        b=oxDTf6QswfaKkTCjj8e18bwmjtMWoAgdA8trACbFUOk7bcgsEoXrraCcOwoI1gbw+a
         btioiM5aizOeNiSGMh6+90anIcE1tqeBdbTC+Vkm5AUpBF/9atFAWYdaX2OMxPuVkqDj
         wUljr5YeIwc012fHyGdotgLRmAP0DCgnSFe2+VPuKM6jfHSv3Z4zeWtI8iejk++LR8nQ
         3aqHqKAWFLtkrs1nfkdM8QrfExFa4Y5wgNEJgt0T6nw9I83cY9B7NbkVpH9vyZpXWTqH
         eUxnGmR+Q2xq3Vn1TG3WQDLRrPbV+Cgj51+wOTME6NrO0sl8r5pR0V1Dw4uMg7FpaAP9
         WAbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=YtKHs6p1hkPZRuLpWntFvRSIJdzjPy+3GlRYlCY9zeo=;
        b=UTonelstzOWmsE6Kod0Gu65PE5j0KP8YAHEC22WvE3xEX+SvVuqMq9dqx2GoFh5zX6
         b+mFJYfrhmbyRuLAn2ipsMgEVQp5EitWSsDI6nO+TUMLQiiQSOUWHAFjEL2hbRliFbrS
         vRhCK2aRVgx4okh2xWvVafcoV86/7VvHZvbOi+CxjjOENq/JxbzsdO07wsjNi1AlI9S8
         AfCHPbVzlgFFW3nM/a6gNRoLRt1jflsBc1UiNMsrd78OdXhA+vfJHztAj+H/4FbG6lBk
         eRjwiz20EpXUXfmDLz2cm9+bgZmRnB8/CLs75+AHD8DEGS0s+zTxBKK/xIUmvGppK/Pv
         vs6g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=PFxJAbUY;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m15sor4555294ljg.18.2019.05.16.15.53.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 15:53:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=PFxJAbUY;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=YtKHs6p1hkPZRuLpWntFvRSIJdzjPy+3GlRYlCY9zeo=;
        b=PFxJAbUY3oljE/GYUKOJwp4FCggishnUO3Kr6jDltu7PA3A8u0u/ym6rfr2ViThhyf
         snAprb5ZbShw7fxJV+WjFiVYyvsSwN6KlDq1LFL70+zila/YrmS+CWrB8dywWPYXjHJw
         GG7B856A9pjVxUOw3pMIT/ZpiMETNx79Gu/ik=
X-Google-Smtp-Source: APXvYqzWVKxlr0GItYvbyic6EJ24xIWsz48QDzqrUwIu4s4fdDrrHWzT09zwM6C4g4sJaetq7RBOLA==
X-Received: by 2002:a2e:9581:: with SMTP id w1mr12027433ljh.88.1558047201485;
        Thu, 16 May 2019 15:53:21 -0700 (PDT)
Received: from mail-lj1-f179.google.com (mail-lj1-f179.google.com. [209.85.208.179])
        by smtp.gmail.com with ESMTPSA id n26sm1344808lfi.90.2019.05.16.15.53.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 May 2019 15:53:20 -0700 (PDT)
Received: by mail-lj1-f179.google.com with SMTP id 188so4549877ljf.9
        for <linux-mm@kvack.org>; Thu, 16 May 2019 15:53:20 -0700 (PDT)
X-Received: by 2002:a2e:9b0c:: with SMTP id u12mr3756157lji.189.1558047200002;
 Thu, 16 May 2019 15:53:20 -0700 (PDT)
MIME-Version: 1.0
References: <1558036661-17577-1-git-send-email-cai@lca.pw>
In-Reply-To: <1558036661-17577-1-git-send-email-cai@lca.pw>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 16 May 2019 15:53:04 -0700
X-Gmail-Original-Message-ID: <CAHk-=wjb-xSQq9XrQ2igYURkQ7+X+2+q5OoqQDkp8evgMmFcYg@mail.gmail.com>
Message-ID: <CAHk-=wjb-xSQq9XrQ2igYURkQ7+X+2+q5OoqQDkp8evgMmFcYg@mail.gmail.com>
Subject: Re: [PATCH] slab: remove /proc/slab_allocators
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>, tcharding <me@tobin.cc>, 
	Christoph Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>, penberg@kernel.org, 
	David Rientjes <rientjes@google.com>, iamjoonsoo.kim@lge.com, 
	Al Viro <viro@zeniv.linux.org.uk>, Linux-MM <linux-mm@kvack.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 16, 2019 at 12:58 PM Qian Cai <cai@lca.pw> wrote:
>
> Also, since it seems no one had noticed when it was totally broken
> more than 2-year ago - see the commit fcf88917dd43 ("slab: fix a crash
> by reading /proc/slab_allocators"), probably nobody cares about it
> anymore due to the decline of the SLAB. Just remove it entirely.

With a diff summary like this:

 3 files changed, 1 insertion(+), 232 deletions(-)

I can not resist this patch, and have applied it. Thanks,

                 Linus

