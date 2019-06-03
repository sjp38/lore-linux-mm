Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61BF9C28CC5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 02:22:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC75727AD1
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 02:22:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Y0YVjjCC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC75727AD1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 578EB6B0007; Sun,  2 Jun 2019 22:22:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 502E06B0008; Sun,  2 Jun 2019 22:22:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A3D76B000A; Sun,  2 Jun 2019 22:22:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id F3E416B0007
	for <linux-mm@kvack.org>; Sun,  2 Jun 2019 22:22:04 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 21so8929710pgl.5
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 19:22:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:subject:to:cc
         :references:in-reply-to:mime-version:user-agent:message-id
         :content-transfer-encoding;
        bh=7g16riKDY5MbDiEYTVuQSGlACMGxDSo3Q56OAwRGRyg=;
        b=PW9sekj1zeP+PzXjxT/4Qq7qrM80MJbF0mi3jHhbw9sLqBqxkg4by52ijSFVa79t2u
         aVrKdW4jCsgKSoQ9Nx7reb541Ux3/+J+PJl3se5UMamqiMXjX/V9WshONey2SVPUGWuw
         iDwxGLL7y/etVNYGGEPDROXx9VO8uYrQ9tmsaYLpYpXb8/rU1BPPIi1pVGXYi6bM+Ba2
         K9ton9NKwgOvFm5ECYYd1ejqjScMk301+LJnx0nTK0bZYqlE+3KU9XT+mK4bqqLcGBsN
         XqK7TpIPcX1DrUOxQ9uIQpvE4fuLatvKq6GjKjh1GV0iT5X6CetOdpH9ZhBU7XPpM+0a
         RTbw==
X-Gm-Message-State: APjAAAVBx2ol3jcveoNdrZCvbTQTqgHlktXqubJ9X65A4G9teCs8fjnO
	Z3HSlZpW8E0GLStiDDckxZug+MAqrBPwytTzh9S8jeiS9Tx5m4sbLORr5Wa8XeEyhQw9PwPunQy
	C60SLG0EQ14qkOJztYyaHkyBUzMRHpZeTqJm0sx7I7jNSHIjgB3+fYA9bINGZoawK0Q==
X-Received: by 2002:aa7:881a:: with SMTP id c26mr29254865pfo.254.1559528524532;
        Sun, 02 Jun 2019 19:22:04 -0700 (PDT)
X-Received: by 2002:aa7:881a:: with SMTP id c26mr29254792pfo.254.1559528523185;
        Sun, 02 Jun 2019 19:22:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559528523; cv=none;
        d=google.com; s=arc-20160816;
        b=o7Dcocmcm3amEGwEbKoL9ZOXhBJ3BuiO98nPoccx5PhO+m4YYMacpletKdAgZuUdDp
         FRW17s9etb7nsRuXXznrulLYzeZIvBDDjZHYeF2Y4S+fcPWl2ee/bws4M0fXqwvUVBey
         WZiD7iTMf28s1TQz5ANDWDyg9560nzDbHR6vZ4P5WlsmqvKpDK0dQQssOm7EXPMq4yGd
         sObKGShDf6aI/3d4GNz+gMcnVkkCbTYB9++Kk8O/10m/2FWpuOfvHWw2a3fZ4TkOZbNf
         ey1AfmVFXL153GQWtDaHn0//ot5Y4jiE9R+WOWZ58XhV/aNhIGcXFpeTdllAbAf/xHJi
         sZGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:user-agent:mime-version
         :in-reply-to:references:cc:to:subject:from:date:dkim-signature;
        bh=7g16riKDY5MbDiEYTVuQSGlACMGxDSo3Q56OAwRGRyg=;
        b=J4KgLLamZSzaldejeWAf1Ebx60XMt6eeRJlNikm1WiPquMvvQqX1k5G6s+hAMofo/9
         YYAOaQp44UZZqWT6viYwW6XPM+m9kSzxKi8Rlu1VRnZUqqg0/yrWI84V3lCGd4euO0cW
         cIbpKSgrB8i+HguWsElIS7ql+eWM5ZW1a/bVXuDhDYQg3oBaSyr8t7Hf/MIFUm+BDRQ8
         unzIOIz1H7gF5zflLYZhZaPkvyIOcKOxXZR1aZzl7cb3Xwe9tOO0I9tlm6WmymRfyTz2
         3jOS7IJ+GZAUe2ftZs/Z12SmOUVuhxlBHc0jRuIGZtYFseGq3Jack28hDB0IEQRMoogy
         i3bQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Y0YVjjCC;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h7sor14889640pfe.27.2019.06.02.19.22.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 02 Jun 2019 19:22:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Y0YVjjCC;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:subject:to:cc:references:in-reply-to:mime-version
         :user-agent:message-id:content-transfer-encoding;
        bh=7g16riKDY5MbDiEYTVuQSGlACMGxDSo3Q56OAwRGRyg=;
        b=Y0YVjjCC8r6200gOkyvDgfSivB+jO6RZyJ98Gr3c8rQNsJR8EOsghAoQ4nPaimM1Tg
         F9kMgPBK19Ehe28uiOMq2yl27iB+z16iJ0+jo0lYtPChQxG2yvFkak6uIyqHzt3krawr
         v8IuGXeBtAOfR0D0IY4Ue34Iq2RmV8KQSZUlOb1qSMP9Vpnzkd9AapWl6zuJi/IwNdY+
         8xAhbg5QYeeE5xaCsgtnaoIyuhO4tgAQTSPsyMtpNoiJAW1vp4W2Bs0A+f3KBuiA4+Jp
         L9JS6fO1eTWa+9jMxQU8167mFdI3eqp0UofbRLQ+15+r5knECtwQyirqubEJDq83hfG6
         DxGw==
X-Google-Smtp-Source: APXvYqwi33nF+j/zzE9YbRqtJC8sDB+xD37ajKbxGJdiK5/840qmnFyF02R6V05i72trVIx+rmarYg==
X-Received: by 2002:a62:a511:: with SMTP id v17mr27463848pfm.129.1559528522768;
        Sun, 02 Jun 2019 19:22:02 -0700 (PDT)
Received: from localhost ([203.111.179.138])
        by smtp.gmail.com with ESMTPSA id a25sm6557531pfn.1.2019.06.02.19.22.01
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 02 Jun 2019 19:22:02 -0700 (PDT)
Date: Mon, 03 Jun 2019 12:22:12 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 1/4] mm/large system hash: use vmalloc for size >
 MAX_ORDER when !hashdist
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ard Biesheuvel
	<ard.biesheuvel@linaro.org>, linux-arch <linux-arch@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>, Toshi Kani <toshi.kani@hp.com>,
	Uladzislau Rezki <urezki@gmail.com>
References: <20190528120453.27374-1-npiggin@gmail.com>
	<CAHk-=whHWqVPWMeNRYuxAd8xnZscshoXUP8SFPmJivJfds5-HQ@mail.gmail.com>
In-Reply-To:
	<CAHk-=whHWqVPWMeNRYuxAd8xnZscshoXUP8SFPmJivJfds5-HQ@mail.gmail.com>
MIME-Version: 1.0
User-Agent: astroid/0.14.0 (https://github.com/astroidmail/astroid)
Message-Id: <1559527990.5jatqytnit.astroid@bobo.none>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds's on June 1, 2019 4:30 am:
> On Tue, May 28, 2019 at 5:08 AM Nicholas Piggin <npiggin@gmail.com> wrote=
:
>>
>> The kernel currently clamps large system hashes to MAX_ORDER when
>> hashdist is not set, which is rather arbitrary.
>=20
> I think the *really* arbitrary part here is "hashdist".
>=20
> If you enable NUMA support, hashdist is just set to 1 by default on
> 64-bit, whether the machine actually has any numa characteristics or
> not. So you take that vmalloc() TLB overhead whether you need it or
> not.

Yeah, that's strange it seems to just be an oversight nobody ever
picked up. Patch 2/4 actually fixed that exactly the way you said.

>=20
> So I think your series looks sane, and should help the vmalloc case
> for big hash allocations, but I also think that this whole
> alloc_large_system_hash() function should be smarter in general.
>=20
> Yes, it's called "alloc_large_system_hash()", but it's used on small
> and perfectly normal-sized systems too, and often for not all that big
> hashes.
>=20
> Yes, we tend to try to make some of those hashes large (dentry one in
> particular), but we also use this for small stuff.
>=20
> For example, on my machine I have several network hashes that have
> order 6-8 sizes, none of which really make any sense to use vmalloc
> space for (and which are smaller than a large page, so your patch
> series wouldn't help).
>=20
> So on the whole I have no issues with this series, but I do think we
> should maybe fix that crazy "if (hashdist)" case. Hmm?

Yes agreed. Even after this series with 2MB mappings it's actually a bit=20
sad that we can't use the linear map for the non-NUMA case. My laptop=20
has a 32MB dentry cache and 16MB inode cache so doing a bunch of name=20
lookups is quite a waste of TLB entries (although at least with 2MB=20
pages it doesn't blow the TLB completely).

We might be able to go a step further and use memblock allocator for
those as well, or reserve some boot CMA for that common case ot just
use the linear map for these hashes. I'll look into that.

Thanks,
Nick

=

