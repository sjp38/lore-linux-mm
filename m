Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45622C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 14:42:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F18EF218B0
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 14:42:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="D3pERqbt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F18EF218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F6588E0002; Tue, 12 Feb 2019 09:42:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A4EF8E0001; Tue, 12 Feb 2019 09:42:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7BC268E0002; Tue, 12 Feb 2019 09:42:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3CBB48E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 09:42:43 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id t26so2229621pgu.18
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 06:42:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=bWN/Ds4yifyduWyWjng4M5eUe6ihpkX+4HQVzLhVysA=;
        b=YetGs5CLvislNvleJeR3bmcmT+50+LXn0UcODeRPKqGv8tdQYPpBqehkpyAYf/+oUQ
         m6/kjUaKi8KZPOuvq+btEbASCGgnZMPjizZtprplr9V3X4P6JW2d46v+b4F9YU24aI2e
         DTYFtJQLHVnomyh4gq8Yg7FjfW1t001ZTtpVAXAGT/kGYItO7EUCETHW/WDzBX0a0wLX
         D1A7KJZd8f8D7AczOM9VjfM6moiSmQZYJizoVk2Adwbtwnbg9lOr+GM/LTAESn1dxdgH
         4fXWP4X0ToGkpCaoWEVidhorilDz5jr5pkeP+N2GaVH7ESgNOyFVEC8SlLb0xxT+VNqs
         7Zpg==
X-Gm-Message-State: AHQUAuay+TOC/wTvxwp4qL0VUaB63kPg+TpygUIvrwPASTrxHQOOtVtE
	5JBUrQjS6418o09qQU3hBiVSufx3QsRjsvifpIPSFYTduzRJUWY8WHi65IrXBok+VVTTQYnx0s6
	SPtH2cPuQ7qPXaVacZTnhTFnzsrhsk3UZg3yH9dB8Ha7TQVFeD7099pq49yxcOsjOwZGv7DaKfs
	bfU/ZI6+0CcsKvlA6DZLH2jmo4meU79UVJvOvIbsAe4nv9u7SRMMBRYJ4ThEtFiLGjkB45ofC1o
	g1hN08EwKc5uXizRJcdpVcpOM3E/xFUdN8uc9kdjyzla/xLylQznJVNmxbrh08oe2OObzhtaKPG
	YqVuNdJvD8ebZ13ucN8IIBdGYxVwuLzfdw0Tp91xHFFuqL5kf45XNtRRIUwDMY0iC+VUy7TyU/7
	3
X-Received: by 2002:a65:6658:: with SMTP id z24mr3973018pgv.189.1549982562887;
        Tue, 12 Feb 2019 06:42:42 -0800 (PST)
X-Received: by 2002:a65:6658:: with SMTP id z24mr3972985pgv.189.1549982562253;
        Tue, 12 Feb 2019 06:42:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549982562; cv=none;
        d=google.com; s=arc-20160816;
        b=ohovkkn42R0SS5OEKCENf7glRk+frRCdO/9WYq9Bg+dxxraKvUcbstO5hWUsvpSKvJ
         uZlnP2OeUY9lmtk5pQooxo2nP5Cvt7RNR7vOQop6ZLQAKWm1PU8LTCRt8vCHGnLtb2hm
         rSULQxZGjfzvbEaaTTj3gyR8qwq2VCfLUxp41aTYOAIu+ePjhPykim62gIwaEgSL7KNx
         IS2d3X08iNQGkgsjP8kJ4LPTMxcXIm+Kjdv+z6mgshzaEMInhjj/+E3hXpmZwLZ14Rcz
         nB76kPcr0ZXKzc1dYnGKeCxuCyZdW8S0EdebUxK0bXzpe4ZPLduVx4fpICo074yh7Jf5
         5YxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=bWN/Ds4yifyduWyWjng4M5eUe6ihpkX+4HQVzLhVysA=;
        b=yMtsq/qK25W/ROUTs6cdt96gLHybGt64zFm2RE1S4sVDJDj7F+B2x9AgJlyxX4s9bd
         597Oq+n8aWZrluTiMP3s0aIkn48Lz8k/jzTRwZjS0wxp/qOSjdh0TSi4Gd49qNjQg+zg
         X8QDo9CsA0J81/IsOK3XvHK03dij1UR/gsmXA/G+wkOcbe+gy4KGsbCOhSwfennPQ6sB
         gUbJUlOcwealJdx1tDnlIJaHX0TTF2HHSP5BuNweyWHgLKLAFMdjfSkyPYciow7V99J/
         mX8Gt9dBRvlVWC1AWdQAfmya7WoG9cOCov0hQU3Mpp86WLd6AOQljpIn+ZgT9zbYlDBn
         HZ/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=D3pERqbt;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f123sor19954630pfc.3.2019.02.12.06.42.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 06:42:42 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=D3pERqbt;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=bWN/Ds4yifyduWyWjng4M5eUe6ihpkX+4HQVzLhVysA=;
        b=D3pERqbtsoIlTIbszyeKTNXPZ+GkLddmdSRUSvwJHDhWYZ0EqlXl5JJAr/GMcG6cjm
         8w5vx8/SDFhkqzbZgsKpqr0f4nZk6teNBoiF5JrHjo07S6czoaoyELtYc71vGpzyzs9l
         NKnFgwCi60/YZdMaMFGrYNIrZJZn2mSb2Q2hCQyeJR0pu0bSXUDOZdvsVvhftOd+WrVn
         CvLXALeXUkj7euauowxZvk3pJCCGMmVB494ZHjnVWNUCk968lBDIAv3zbmoFePfV+G42
         kpqNIiqSitztWYrh796I+tCga+Avu7baBk7xTqV0UC/zalFM85YdC+Wi6QZRI4PmQ/WT
         b3dg==
X-Google-Smtp-Source: AHgI3IYgtw7553bt/kX1nbTlW7KCUUqhRqSJL+6wm63TySJUMnntddOnlFpHAngJvAlvJHA369dBbKh2JM1nLqBFX/I=
X-Received: by 2002:a62:6047:: with SMTP id u68mr4229328pfb.239.1549982561579;
 Tue, 12 Feb 2019 06:42:41 -0800 (PST)
MIME-Version: 1.0
References: <cover.1549921721.git.andreyknvl@google.com> <3df171559c52201376f246bf7ce3184fe21c1dc7.1549921721.git.andreyknvl@google.com>
 <4bc08cee-cb49-885d-ef8a-84b188d3b5b3@lca.pw> <CAAeHK+zv5=oHJQg-bx7-tiD9197J7wdMeeRSgaxAfJjXEs3EyA@mail.gmail.com>
 <c92d6890-a718-a968-9937-13bdfeda773c@lca.pw>
In-Reply-To: <c92d6890-a718-a968-9937-13bdfeda773c@lca.pw>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 12 Feb 2019 15:42:30 +0100
Message-ID: <CAAeHK+xDYvjMxrkczTQaDbMSu5u3GsxW_mFi1=9OAjCi2Q-6iQ@mail.gmail.com>
Subject: Re: [PATCH 5/5] kasan, slub: fix conflicts with CONFIG_SLAB_FREELIST_HARDENED
To: Qian Cai <cai@lca.pw>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, 
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, 
	kasan-dev <kasan-dev@googlegroups.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 2:43 PM Qian Cai <cai@lca.pw> wrote:
>
>
>
> On 2/12/19 8:26 AM, Andrey Konovalov wrote:
> > Hm, did you apply all 6 patches (the one that you sent and these five)
> Yes.

I'm failing to reproduce this in QEMU. You're still using the same
config, right? Could you share whole dmesg until the first BUG?

