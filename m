Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10BDEC3A5AA
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 00:40:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9EC7121881
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 00:40:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GOOIgAyd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9EC7121881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 10E596B0003; Wed,  4 Sep 2019 20:40:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E5126B0005; Wed,  4 Sep 2019 20:40:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 022946B0006; Wed,  4 Sep 2019 20:40:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0096.hostedemail.com [216.40.44.96])
	by kanga.kvack.org (Postfix) with ESMTP id D6AE96B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 20:40:39 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 7C41F180AD7C3
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 00:40:39 +0000 (UTC)
X-FDA: 75899011398.23.sense52_5b2f0b67611a
X-HE-Tag: sense52_5b2f0b67611a
X-Filterd-Recvd-Size: 3244
Received: from mail-ot1-f66.google.com (mail-ot1-f66.google.com [209.85.210.66])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 00:40:38 +0000 (UTC)
Received: by mail-ot1-f66.google.com with SMTP id r20so404175ota.5
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 17:40:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=OxSkqoSh+0HMVxSUeqDi0SoEqFfeyqeJm0b071hAlMc=;
        b=GOOIgAydwTEpRK2ZdTj4eZDpiSmni0FBcYW5siDWuc+gMvN5ZYahvytiku4Ht5oMlY
         gl3OGEN9sKy3u3QXUdgGMbiS6gYDUCLkiJ6q3BjMhjUzV/XgGW1yIX2PycokViLX887E
         IOcctW1TeTwXu7/uhikJCh5NGET1A38LkkPK6csSVDN/D8bIReD8yohlHchLvlizNH3D
         tP8VAI2E1gHs9Hft3AIV3mTL3lRVkANaAlVVf31WJMTQz7Ag1XOcwoVSG0AbMIQeCGoD
         PL06AcTyDDaM23v+NtXb8TFomlWkO8SH/jKAiHHWORsMCM7y1luqzJaPcBhgeoTBXPgF
         mYXA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=OxSkqoSh+0HMVxSUeqDi0SoEqFfeyqeJm0b071hAlMc=;
        b=HBUlwHzhrEoWIPwcf7DDDHG55zhf+2QrkLcFF6tEtB9qV8S0hVFM6RnDxXwmZIyReO
         PCroxJDrM7RwkZs18YIC8I+zerjAIDv1xGnXH6BD1wLtEXODpgopFGat3ZSNg9C/lACF
         ycGqML+XXCZfQQsUn5GdaIb+Xmej2IbAq2HYwItRZEkahSgLy3HbvI/zg+Z5avt9kjJO
         CoE07lH8msi/Q6voRv+ZT75ZQJ53E9VFe/BkPUw0gdTfvF6JhIY/LGKdzTPKv5KSiSUS
         8BgOerh1YL2NZ00Eb8S5z4sefsGp0gAtqLyVV90FHbrHZl1j7n7qzmdIrdynQqBGP7eE
         2j3w==
X-Gm-Message-State: APjAAAUUkyFq1LgotA/95wf45CIBdzm3PrAZuYz/yvLrumn5A7LPXgA3
	E8wSbCCBpd1u/zzf4gts+mDw9yXFsJK1do+lhUc=
X-Google-Smtp-Source: APXvYqwpWI27z+3wJ9vL6rM2vr1U09kEUHx4FuxLxEBZI6pcKzLchmXuVNPu6Ilu+wSjcguXf/HMFdkvfAocIQhPXes=
X-Received: by 2002:a05:6830:1e96:: with SMTP id n22mr285018otr.368.1567644038405;
 Wed, 04 Sep 2019 17:40:38 -0700 (PDT)
MIME-Version: 1.0
References: <20190903160430.1368-1-lpf.vector@gmail.com> <0100016cfdbed786-8e9441ab-4c0c-4d2d-b9dc-d1d6878481b8-000000@email.amazonses.com>
In-Reply-To: <0100016cfdbed786-8e9441ab-4c0c-4d2d-b9dc-d1d6878481b8-000000@email.amazonses.com>
From: Pengfei Li <lpf.vector@gmail.com>
Date: Thu, 5 Sep 2019 08:40:27 +0800
Message-ID: <CAD7_sbEM5KTLzWjEWB__jhK+NrzANnBnHK4=xM6Wq4V7ziF3_g@mail.gmail.com>
Subject: Re: [PATCH 0/5] mm, slab: Make kmalloc_info[] contain all types of names
To: Christopher Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, penberg@kernel.org, rientjes@google.com, 
	iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.003425, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 5, 2019 at 3:27 AM Christopher Lameter <cl@linux.com> wrote:
>
> On Wed, 4 Sep 2019, Pengfei Li wrote:
>
> > There are three types of kmalloc, KMALLOC_NORMAL, KMALLOC_RECLAIM
> > and KMALLOC_DMA.
>
> I only got a few patches of this set. Can I see the complete patchset
> somewhere?

Yes, you can get the patches from
https://patchwork.kernel.org/cover/11128325/ or
https://lore.kernel.org/patchwork/cover/1123412/

Hope you like it :)

