Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0CDDC0044B
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 21:12:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5BA77218EA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 21:12:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="Oa6aKfGJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BA77218EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE7278E0002; Wed, 13 Feb 2019 16:12:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E94C88E0001; Wed, 13 Feb 2019 16:12:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D5D198E0002; Wed, 13 Feb 2019 16:12:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id A897C8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:12:12 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id 65so3478918qte.18
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 13:12:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=MiwKzC4imTfd9YcBKHOMCvIKJMLvOZ3tgWAcHt8ruuY=;
        b=fPnyaNzcTKXxDipHMXggG4p1nU3iObxqCwGg0Yw8wJZga4l4kjYM0UIGPTUgOI4W7d
         4ETAZCQIh7IPALfIlxPH/wyPsmc+ec28s3hVAIJQaSlnFcdZrYPOEjmaYVWnrv0Nez9W
         0loPZV8fEVaNUNzw/vucQKTYoG2Aweqq+1cUMA6OGP0NthGi+CCz+e9GxhDlLJockAOw
         8ZX0IdvKCbmPBTc4b4HOHCCFofIanv0ydVeZ25pwViQdaisMqUZnIAci1SHnCbx1w7on
         2aveYKdw6gTtLVPWMS9AWe3kVRO8Yt0Jervn8nnTzdIabcE1h0BJ6NRUONMSmVgzAQMC
         ayFg==
X-Gm-Message-State: AHQUAuYtDIyhIamEXWojKRzdc6eIsoN9L4+sSgCXv2ZqbRnRK+LbXuAy
	2x6gVxs+mG6upvFhY98DGNpJGe7CCwHb8ETfTzmLnBBfafwRvOERlzVjA4NuxTbOUP9HSgW5sZ2
	Djm0For2zqIGfR/b93aElvV5tsGyyC6yRgBYEYd+pJtR2sg++MtUo2O5AufC5jAq+U/Viaua4an
	VdxpidZDGyOtUN6wBfFFb44kedUYWwiB9GPCyHkgN+0nuT+703izbEo99GqvLxZBNhQkHoIYZrj
	zr5Hrp+PfPq0oSj2QplcuZU8x87DFpKpfo+7fwRld4+vjjgntQO35ce8LRH2W5g6wzhtDEQC0GU
	B5AJy4P0xFQUnadb1VqW8o4Z7zB+wZRKzQLLTc93MF77WQvxoBIytjnOgmm/dB9s8MCu5d1UMLU
	K
X-Received: by 2002:a0c:b626:: with SMTP id f38mr161022qve.166.1550092332436;
        Wed, 13 Feb 2019 13:12:12 -0800 (PST)
X-Received: by 2002:a0c:b626:: with SMTP id f38mr160967qve.166.1550092331771;
        Wed, 13 Feb 2019 13:12:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550092331; cv=none;
        d=google.com; s=arc-20160816;
        b=PGw0AvbOybVw0vL5ajI5kI1O2KgyJ7L9Wz33S/yK24O81Ov5bOGDIxU8sr+nNy4MtN
         COX23pNYN+erkyko0iaghg+QbgO1ELShouLuJQU+3Qu76JGvnxa+yzUhu3Mu7Os3rpiT
         5W+VDQ+/zSsliZRCYi4SktBSe5hpVgISntnU1brqmtgteKOQV3CIc4cNoJVuAszj6djS
         nPMFXCuRxjip2UEyG4OsbUUkxTfS5uWhUfZVrDk/NVWgWAaNKn4CFe8nvbfk26+hHTpA
         mVidRsRzncVD7qRfgex/FCXCZDpV0AIVvGoeMyTaoNp43vYw4LuiB0g9+4AKHF8K/pGD
         R+GA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=MiwKzC4imTfd9YcBKHOMCvIKJMLvOZ3tgWAcHt8ruuY=;
        b=u9tm0d8N8cP4Ndq4x+2UHxEkUSGh0G3Cwnj3LRxDHkV4HLHy+6ZCCvL9awwaXsFN6J
         8ovhAKO2CC5/REijvfUefiIQqVKJSgPL+t4tyMZFKqMF1eBfKy5RKG69Gt4XnVKqV4wt
         +Ktsxd4P07TeG+HJLsyuItZbEhHJSkVmpYAboviARTNwltFoIkS/0ma+s2wY421IIWq6
         8eo0/22IBFk147YfHxoPCzXXOgf6uHvkHJc8Jr8gAjgqpWykRfFf8rJ3GeepRvhf+TPO
         o8VH4GnMBAC1uAbya9i8gP5eGzcnL+IXLy8IljTdG701yfmp6KJ6VrfHzhLxWJYzL4mE
         JrRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Oa6aKfGJ;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s2sor471428qvs.23.2019.02.13.13.12.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 13:12:11 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Oa6aKfGJ;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=MiwKzC4imTfd9YcBKHOMCvIKJMLvOZ3tgWAcHt8ruuY=;
        b=Oa6aKfGJV49VQzZRz7eGabgXeocEDhQI2NULInrB7+KIlp0w0iUKai+8Ot9Up2sguP
         2GL2gtQYS74J5pq15ULP+A/blFvHnKCYpZ2efsq7eb3W/nR0m9lhfATbjXm49n3Org6P
         U4VOoCYjel7aU6c9pYjbLCgQNLokCjI104tu5mjHNUXPJTfxvGIHKgth7TIH2Xpsbptu
         kb9yVwCDC9fc1UCC5VoZ2XNN5BokGqsFK/FJPuTtvu1kcHRJHCX8SaR/ry4fU4zajL7f
         rrIgKl3n+Sgo/260TrHTEe2fk5SMkTn8FWuOOfhtll2cKd6CEhkm3kHfSoR75qQdz/Qw
         zBxw==
X-Google-Smtp-Source: AHgI3Ib3MgeYUD0kj0bVIyGhAzcL8goNj/KR85py2uRk370sl0TzokE3P694GevZS8gTbhoZfKeLbg==
X-Received: by 2002:a0c:b068:: with SMTP id l37mr148913qvc.21.1550092331303;
        Wed, 13 Feb 2019 13:12:11 -0800 (PST)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id t2sm234914qkh.60.2019.02.13.13.12.10
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 13:12:10 -0800 (PST)
Message-ID: <1550092329.6911.35.camel@lca.pw>
Subject: Re: [PATCH] slub: untag object before slab end
From: Qian Cai <cai@lca.pw>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter
 <cl@linux.com>,  Pekka Enberg <penberg@kernel.org>, David Rientjes
 <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,  Linux Memory
 Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Date: Wed, 13 Feb 2019 16:12:09 -0500
In-Reply-To: <CAAeHK+w-EWDivYTNiUAeSUVZVGOpUyxbbcC8_nMM1=CcpsJ9Ug@mail.gmail.com>
References: <20190213020550.82453-1-cai@lca.pw>
	 <CAAeHK+w-EWDivYTNiUAeSUVZVGOpUyxbbcC8_nMM1=CcpsJ9Ug@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-02-13 at 11:31 +0100, Andrey Konovalov wrote:
> On Wed, Feb 13, 2019 at 3:06 AM Qian Cai <cai@lca.pw> wrote:
> > 
> > get_freepointer() could return NULL if there is no more free objects in
> > the slab. However, it could return a tagged pointer (like
> > 0x2200000000000000) with KASAN_SW_TAGS which would escape the NULL
> > object checking in check_valid_pointer() and trigger errors below, so
> > untag the object before checking for a NULL object there.
> 
> I think this solution is just masking the issue. get_freepointer()
> shouldn't return tagged NULLs. Apparently when we save a freelist
> pointer, the object where the pointer gets written is tagged
> differently, than this same object when the pointer gets read. I found
> one case where this happens (the last patch out my 5 patch series),
> but apparently there are more.

Well, the problem is that,

__free_slab
  for_each_object(p, s, page_address(page) [1]
    check_object(s, page, p ...)
      get_freepointer(s, p)

[1]: p += s->size

page_address() tags the address using page_kasan_tag(page), so each "p" here has
that tag.

However, at beginning in allocate_slab(), it tags each object with a random tag,
and then calls set_freepointer(s, p, NULL)

As the result, get_freepointer() returns a tagged NULL because it never be able
to obtain the original tag of the object anymore, and this calculation is now
wrong.

return (void *)((unsigned long)ptr ^ s->random ^ ptr_addr);

This also explain why this patch also works, as it unifies the tags.

https://marc.info/?l=linux-mm&m=154955366113951&w=2

 

