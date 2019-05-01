Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED26FC43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 18:25:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6DF420645
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 18:25:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="hu/9UibJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6DF420645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 379866B0005; Wed,  1 May 2019 14:25:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 329D96B0006; Wed,  1 May 2019 14:25:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2195D6B0007; Wed,  1 May 2019 14:25:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id F3F3C6B0005
	for <linux-mm@kvack.org>; Wed,  1 May 2019 14:25:39 -0400 (EDT)
Received: by mail-ua1-f70.google.com with SMTP id o64so2071950uao.5
        for <linux-mm@kvack.org>; Wed, 01 May 2019 11:25:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=CL8fj/1WvD1XOCsOkJZLbwr2FkrpulNbESBS+POuiy4=;
        b=p45yzwICk6qpLcD1vdvSIuHiP4rzSez95ns6VWsMzy/1o1B6AImn5VnktjIcUXHW1h
         mYLcn2ykMVAYZAylZTKdNdAYHeB6o6DaQNf/c5cT2s1QcD5gbHuhqpmzTUoGZEX0bOQm
         suVoM5sAy1xdXlvOFkIbpLTcw0p0bbWSVIpQhvRzxYnI6t8Pla5ZJbN5oJoXXfQGGwiI
         LuJVPD33vANmrbD6BPFEidmmDJTZueCPSz1ABAAYkA5zzysjhVTCT5XMUgZWQ5QZN/+H
         Uc2p6BtAPEUqmgh8kqFZtZ1lyEBA5fkssSMTCy+jVG8+2M6WPXmcoBNJtbS356/LoDfh
         +1Ug==
X-Gm-Message-State: APjAAAV7tDItq4JGAFhVg/w1DyKuBl+1YnRKtsV23/yIzo3LSosoXqjD
	Ou3MDn78Gp3PE9LLzFEmLcs8UUjOD1b3Y+eGelfITpe/S7BzH340sJM7rAqPCmd6CdoPs26Whe7
	nNXX9j25xVxk099ba1YTgsOv+rt54XHEdQ/Y3BbdWeU5PRdnVFcmEaZo5QKpVXOC8kw==
X-Received: by 2002:a1f:f03:: with SMTP id 3mr24021765vkp.2.1556735139531;
        Wed, 01 May 2019 11:25:39 -0700 (PDT)
X-Received: by 2002:a1f:f03:: with SMTP id 3mr24021735vkp.2.1556735138914;
        Wed, 01 May 2019 11:25:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556735138; cv=none;
        d=google.com; s=arc-20160816;
        b=tyCFNxWtFP9ru2jKDdfJXtcYndyuby5yMPcRC7o2rTq1VH2gmTWsJuAsCs5zO278k9
         HrxF9iGx1hTRnDphFxc9Oo4EWOGYA768JLuIkMerGDG0qTWOCGP2Oz2JOZswjZoFliIH
         6OfSUdcXqBTSjt8wBydkdJ7BJaEwDVbYrTWLKktNoyFYucumxMmM3BLpGHGOLiPJbl6y
         Sm606kl5TFQcXoa1TKsghoh0ZmvcE4X3AVc9ViR5lQ0e86eGxAxkalZO6zfYx+sw0qq8
         gCoa64fhFpmqc6GG2F3+0b8XYj4bMzNfcnUwQluWCJ7tDGAgJAmHyjgne7WeQqPhAeMT
         LMoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=CL8fj/1WvD1XOCsOkJZLbwr2FkrpulNbESBS+POuiy4=;
        b=JBViMRxSVLud9qW5UjJcw1Y7R+CrqrBCNnYFZKUKkogyolBzl4chMTz1QEeG3qvCF+
         gsZ44U9am+w50KszrhPIqOhZBM8zor82n0hEXZOSbcjjJUJ+wlpH+qHkyt5hzITqqPcC
         ysOHIhioaRF522kx4JjIbSNTqPpxpI81P3LeUPr+j1i9vrMo9+XtauIk5ds/iRzc/ewG
         MZJtptbXC51v+IhDhvjim/4BOZWfF2uHQGvcixJfvyJDAiIJd5paRbi6Vo43KVp3x0sm
         s8Vmz69qOLMK2uTnHM2SLTL6KETW7IBlil0Cc646Id9iSoLHzCE5FmmCHGAI+KX73IaM
         RFQA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="hu/9UibJ";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d16sor8842445vkf.53.2019.05.01.11.25.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 May 2019 11:25:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="hu/9UibJ";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=CL8fj/1WvD1XOCsOkJZLbwr2FkrpulNbESBS+POuiy4=;
        b=hu/9UibJbGHN4C66jypCqfrbpjHMgUcaeYXOGUNbli3BiwRurGxcpdiXWQHRQ5i06U
         Y11FqcRwwKe4Azn+8nSK+mXnIP8Lr8lTLiTGRZ3nr/fhzubOnGjrJnrDWU/Dpet3fmLk
         YEKBuYVr+e4TorKS95zgT9WAQiACfYixLAVkA=
X-Google-Smtp-Source: APXvYqwCLuIHzxo2se7JImhbpxGI5cR9ju5C7SdGfMXMdcy3owZ7NWRdWsDMkeOJo2KpMHvTiJF8vw==
X-Received: by 2002:a1f:2fc7:: with SMTP id v190mr39074075vkv.84.1556735137713;
        Wed, 01 May 2019 11:25:37 -0700 (PDT)
Received: from mail-vs1-f46.google.com (mail-vs1-f46.google.com. [209.85.217.46])
        by smtp.gmail.com with ESMTPSA id u3sm6012021vsi.2.2019.05.01.11.25.36
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 11:25:36 -0700 (PDT)
Received: by mail-vs1-f46.google.com with SMTP id j184so10279068vsd.11
        for <linux-mm@kvack.org>; Wed, 01 May 2019 11:25:36 -0700 (PDT)
X-Received: by 2002:a67:f849:: with SMTP id b9mr39824551vsp.188.1556735135694;
 Wed, 01 May 2019 11:25:35 -0700 (PDT)
MIME-Version: 1.0
References: <20190501160636.30841-1-hch@lst.de>
In-Reply-To: <20190501160636.30841-1-hch@lst.de>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 1 May 2019 11:25:23 -0700
X-Gmail-Original-Message-ID: <CAGXu5jKMswkBy-kEk7mb01v3oJADvGyhRf6JMh7BsjUKsme9QA@mail.gmail.com>
Message-ID: <CAGXu5jKMswkBy-kEk7mb01v3oJADvGyhRf6JMh7BsjUKsme9QA@mail.gmail.com>
Subject: Re: fix filler_t callback type mismatches
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sami Tolvanen <samitolvanen@google.com>, 
	Nick Desaulniers <ndesaulniers@google.com>, Linux mtd <linux-mtd@lists.infradead.org>, 
	"open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 1, 2019 at 9:07 AM Christoph Hellwig <hch@lst.de> wrote:
>
> Casting mapping->a_ops->readpage to filler_t causes an indirect call
> type mismatch with Control-Flow Integrity checking. This change fixes
> the mismatch in read_cache_page_gfp and read_mapping_page by adding
> using a NULL filler argument as an indication to call ->readpage
> directly, and by passing the right parameter callbacks in nfs and jffs2.

Nice. This looks great; thanks for looking at this. For the series
(including patch 5):

Reviewed-by: Kees Cook <keescook@chromium.org>

-- 
Kees Cook

