Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E925C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 13:07:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 38E382084B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 13:07:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="gj3d2dIg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 38E382084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0E3D6B0008; Wed,  3 Apr 2019 09:07:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE54D6B000A; Wed,  3 Apr 2019 09:07:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AFBEC6B000C; Wed,  3 Apr 2019 09:07:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8F0576B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 09:07:53 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id v2so14479760qkf.21
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 06:07:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=6TbXx470gB2/L327MHubCCa9FGqzdEttkYRsItRZ/js=;
        b=GzDo11OsKf1zqm1W6hUcXm1EJK2AlyYa74cM1QOR5oKAK2nwXd/myQ9SKFzfV9wxfp
         lxTyCGOhdlhRiKMFIob2WaW5NuAf0eBB9gjucJHElS+XCJfYcqhPqI8wC0j/G8Z/AxXR
         95aeX6AqNDsjprsDN2Lx/q5c8BNS6ycYRJvX8GrOi+ZvbJzYqueMYcCd88JoTzezm6ht
         +t4YqWHsKGwpgSTtZch7Klu+jPe451aKrxxawTDN2u9uAMaHqXge61WiFcdA1F3F+Svx
         bbqPmIEWdbxxwbOe3BZYt/Hf9gDDWePAiIITPNfX5C2dm51B+aDEAjMinGQ8JHE2cY19
         w+0g==
X-Gm-Message-State: APjAAAWkdR79CxEgciXUTh7wBaTBxI+l0B6u4RquFst1a12ad8fzFnAp
	XK3JJrXl0Pe+0woe/yOIrTGT965NLnG7ZQn9//EUFGPfh3wDroR9fxIsb+R47hBKsKETAZgeOSg
	VwLhzKYGNRE/ZD7+Ea4eemkU/fL3V4fMRQmX3lQ/MUlAKGFG4CNfJsStrr2VnBDjmvg==
X-Received: by 2002:ae9:ec18:: with SMTP id h24mr5258637qkg.207.1554296873318;
        Wed, 03 Apr 2019 06:07:53 -0700 (PDT)
X-Received: by 2002:ae9:ec18:: with SMTP id h24mr5258561qkg.207.1554296872562;
        Wed, 03 Apr 2019 06:07:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554296872; cv=none;
        d=google.com; s=arc-20160816;
        b=WcBnYSDNLW24re6VDHNepGg/n+5e+IVje7bzGotb403C2+NQ9NC6p0ky4OneyRVk6S
         S/BrZW/wMh5xlDC+12a9Z1vrkMzywitDaV474RJnHQdymROl2mPBtLZzdJ7zXyAuK30w
         nM2zlleG+xMPUA8VD8epwbF7k6uHUJ6bHH8dggOizkCGAbt4waZwxPHXb4QJOiXEHVaY
         bmba8KldJUT3hds4lB38dqtFb801rne2/ou5XTMrCgTnJHtGirCKAXihoQ+dIiBrstRv
         hdQ7/V93x7jGmFAEaXa0La+f1qZejDXz/f1uwYncN7aTkp0yQPl3FBjVYWts0tNuv60p
         ZGBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=6TbXx470gB2/L327MHubCCa9FGqzdEttkYRsItRZ/js=;
        b=tV7GtWakzVarjNcZJj6ZSw8H81s+IIuyuu+jsEFpnf44HElZfbg8dik9vOhfLurR7W
         wtMvk8T7KsEwilSttTBXVXn/f2UyX6+liJRosNe6n6vDAcapFUfnNIPbxDgdhvLFhF9A
         3p3tGDQu19VLuZOoasdO+FyV5ZwbZ/cvhin331WzkUC1GGpTp+SbmgQX4W2Yed+T5n7U
         PN9rci3SN9wB4thNXUSdp1pIKlVJbt/5/1/10g1MbGlkNY3ILJsTYB8bpKLoFd4A+JEP
         YgILJIN4a16DCQyXdMFl1xcxp4bMN7XIycDGFALw+0ewXegoHLBOjGA+ub1mlQT0PgDx
         ewCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=gj3d2dIg;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x4sor22453706qto.38.2019.04.03.06.07.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Apr 2019 06:07:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=gj3d2dIg;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=6TbXx470gB2/L327MHubCCa9FGqzdEttkYRsItRZ/js=;
        b=gj3d2dIgyS1juous1+rrj5kPXgzLNcDgCTr0MjFUCmXxbywzvPEbuXfBhNfDjC1N61
         CMGh6M7pxGvStFupFAXAL40cY305TZmNYiylRnPoXmCIzQGxiPbCnqdVKmF24zamew3f
         wUNbwizEnVexKfzbEK/xTornjseE5OAqSvInI36+WiWJB1fsyhjYID9AR9MV9LOsoKGH
         mIgaeq/jub+ukXx0pZt8vkjbglYCRAVr8KrhLWylg0RElkC5hZ6AkIu1V18C4/vWsdtO
         A0FjzOj2TDtxxN4Yz0HfwFkvJVZOvGGedSsWJ5PR0iuS44JwO4BYQQrIY6V2DiSCXipQ
         JIoA==
X-Google-Smtp-Source: APXvYqzEEHgsgkai8JhpGANOP06QXmX0CP1vzaNNrNU61AclZARASaHB8UoGll4tCJ6GJGEk51f24A==
X-Received: by 2002:ac8:66d0:: with SMTP id m16mr53517935qtp.215.1554296872208;
        Wed, 03 Apr 2019 06:07:52 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id h2sm7013076qkl.3.2019.04.03.06.07.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 06:07:51 -0700 (PDT)
Message-ID: <1554296870.26196.32.camel@lca.pw>
Subject: Re: [PATCH] slab: store tagged freelist for off-slab slabmgmt
From: Qian Cai <cai@lca.pw>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter
 <cl@linux.com>,  Pekka Enberg <penberg@kernel.org>, David Rientjes
 <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,  Andrey
 Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko
 <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev
 <kasan-dev@googlegroups.com>, Linux Memory Management List
 <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Date: Wed, 03 Apr 2019 09:07:50 -0400
In-Reply-To: <CAAeHK+y25S6GYMrGUEQJJ5AU1LZ7T-jWrwoDsLXdxuk_E+q5BQ@mail.gmail.com>
References: <20190403022858.97584-1-cai@lca.pw>
	 <CAAeHK+y25S6GYMrGUEQJJ5AU1LZ7T-jWrwoDsLXdxuk_E+q5BQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-04-03 at 13:23 +0200, Andrey Konovalov wrote:
> On Wed, Apr 3, 2019 at 4:29 AM Qian Cai <cai@lca.pw> wrote:
> > 
> > The commit 51dedad06b5f ("kasan, slab: make freelist stored without
> > tags") calls kasan_reset_tag() for off-slab slab management object
> > leading to freelist being stored non-tagged. However, cache_grow_begin()
> > -> alloc_slabmgmt() -> kmem_cache_alloc_node() which assigns a tag for
> > the address and stores in the shadow address. As the result, it causes
> > endless errors below during boot due to drain_freelist() ->
> > slab_destroy() -> kasan_slab_free() which compares already untagged
> > freelist against the stored tag in the shadow address. Since off-slab
> > slab management object freelist is such a special case, so just store it
> > tagged. Non-off-slab management object freelist is still stored untagged
> > which has not been assigned a tag and should not cause any other
> > troubles with this inconsistency.
> 
> Hi Qian,
> 
> Could you share the config (or other steps) you used to reproduce this?

https://git.sr.ht/~cai/linux-debug/blob/master/config

Additional command-line option to boot:

page_poison=on crashkernel=768M earlycon page_owner=on numa_balancing=enable
systemd.unified_cgroup_hierarchy=1 debug_guardpage_minorder=1

