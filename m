Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29BF9C282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 08:35:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC9C820835
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 08:35:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="K6OCI8g8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC9C820835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5FBE36B0007; Wed, 17 Apr 2019 04:35:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5ABD06B0008; Wed, 17 Apr 2019 04:35:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C2916B000A; Wed, 17 Apr 2019 04:35:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id D5F5E6B0007
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 04:35:15 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id m7so3366884lfb.2
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 01:35:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-transfer-encoding;
        bh=HE9AdSyj6Xu+M4CDNxaUyXeYyEky8JqgeK1vrcackXY=;
        b=fxFHdbLQuDoEgIYa02Mglg72ma3ilQf+lrzsI+EiHH6hZBk84pevEl27Uw16kqdvJH
         lQU3PKBCjEJjB/9MUnlCTIqR9M2AoAV71AyRXanmvxuSv11IyWuOtL3XyoCewDu8XPbL
         gdb9XC1U1rcUODCyO6xVsvrc/3jeZOvHcPxqZFY1SJz9go0ciO+d2LJW07u6SGJYA3cp
         Mw6BV+L/Krcpw1krh26zgqVLyQxIKulFYZgGw1C1rs0KL31uoWWvFqczQUsILErQqgIO
         svMoQoSffYM5sAJ2UCLL6qsdU/duzaMD8QpsbV2uqb19Q6OGLbYioxmy9yEyZX2lHRu4
         4OJw==
X-Gm-Message-State: APjAAAXHLqbBQ2Oybw7/46JWrnMcFNBBQ7poDFybxU0ptGSJUiE6sLrn
	hhV5RO6+gOE2eIhjwpqGIcDAGQvZV+244Opq51VykrAkQb8C0RnIda6Tbli1sYne6rttwu7LrUW
	dEMsZOmnBuatnYSHC+ttvg3dY7uqPPZMf9S2OWjBun0PFlmkc9mFZAKALnQuNLVkDgw==
X-Received: by 2002:a2e:5d94:: with SMTP id v20mr46261732lje.138.1555490114983;
        Wed, 17 Apr 2019 01:35:14 -0700 (PDT)
X-Received: by 2002:a2e:5d94:: with SMTP id v20mr46261664lje.138.1555490113630;
        Wed, 17 Apr 2019 01:35:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555490113; cv=none;
        d=google.com; s=arc-20160816;
        b=GKwKj2PyQjtdLfx7/psQ/UrAJx9JlWCCyaKPlozKkwrTBmD6B2B8pV30HVTX0ROWQZ
         RRXP5rSt4gabgf5hBy0YvHjQ/2NC/FkjUqC23uImu7hkuW/WeJJcfgFZ+hfrFQBl95Sw
         m+7TIhIKJ8VJ3xrnDypppyrAtjOoxJS1P6C9OWmL/c7skvJWBFNcHAmWPlnEpVj122on
         5x9NgAG9RVcr4KvqwMq8+JpSYQ1rHlZgLawwSDgvsscsYVV/ICIgLJ28gm63tufuEMB/
         7gZ3+TyUMm1YsYbIXmYk6GwmnqJWME7PoQocrq2jeiY2NQ0veDNsH0h4Oyv7+WushtAm
         L6EA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:subject:cc:to
         :from:date:dkim-signature;
        bh=HE9AdSyj6Xu+M4CDNxaUyXeYyEky8JqgeK1vrcackXY=;
        b=M7NMrocyKN6keUI0W/8wzZe0wBEviWmZdwSxS6lk+zzX3NjSqmHBwV4LDTy5X/cf/5
         a6UoHmNSxsT0vtf3PDcVlb+GC+VsC4o4Gh9s+cO3rhvHU9kbegbDFbRs6snqa4IBKLxQ
         1SGNk9raZdxcT1afOJezeJPMM8hJhBbkoV/j8yIce7vBrKNLmuLKM3SDKYb94VI0XoxW
         soqI2paZpwtth9Lb3RsayGlBTWevBLK2NKNuMpPHWczk2XhhPEdQUfpDsSkmUtnK8Pr5
         OZhEuWOdJARTRvuduSpZwywdaJbesuwpCyHdfxghdE9llVK/LEcUgugAwmznqBegl0WU
         5qWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=K6OCI8g8;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x26sor33033156ljb.16.2019.04.17.01.35.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 01:35:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=K6OCI8g8;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version
         :content-transfer-encoding;
        bh=HE9AdSyj6Xu+M4CDNxaUyXeYyEky8JqgeK1vrcackXY=;
        b=K6OCI8g8E1m2UF7ZmFB5XQHjq7lCGpCRt5EP3S/RYWBTjDZKQy+vkRJ1YLzJxdAMO2
         gFgiZwLZDo0nGfIFeLDqho1yCZok4AnOwB8xj5U+jQqzyCYIwSvCgblhUytiX7r+qzlm
         9NUw4uBpzm/BQKaupHy+yN3dPC8wcMyAu5l3UlFcKhQH306tKiICIHF+AkKmwnou09F4
         eCx2zUPWQQx0/K76ybi2GlZA7tAvQ4fEyj19duwnU7fw/WV4fDGMnskt6ttdZ9gL2n7y
         jNszH93UPC20ttfkS/w8OnUVC285KZeEef5ITr26Nu97XAyZOnkT8ifH9+FFf8mbAl4h
         Z0mA==
X-Google-Smtp-Source: APXvYqx/1W7r5BcBsBGdz4XhIoiPlTwQRfInV4VnPM6C+id0DSBq01qwWcbQQtDXgXTEOKmRO/N7Cg==
X-Received: by 2002:a2e:9811:: with SMTP id a17mr35692132ljj.96.1555490112620;
        Wed, 17 Apr 2019 01:35:12 -0700 (PDT)
Received: from seldlx21914.corpusers.net ([37.139.156.40])
        by smtp.gmail.com with ESMTPSA id s24sm10762311ljs.30.2019.04.17.01.35.11
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 01:35:11 -0700 (PDT)
Date: Wed, 17 Apr 2019 10:35:10 +0200
From: Vitaly Wool <vitalywool@gmail.com>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton
 <akpm@linux-foundation.org>, Oleksiy.Avramchenko@sony.com, Bartlomiej
 Zolnierkiewicz <b.zolnierkie@samsung.com>, Krzysztof Kozlowski
 <k.kozlowski@samsung.com>
Subject: [PATCHv2 0/4] z3fold: support page migration
Message-Id: <20190417103510.36b055f3314e0e32b916b30a@gmail.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.30; x86_64-unknown-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patchset implements page migration support and slightly better
buddy search. To implement page migration support, z3fold has to move
away from the current scheme of handle encoding. i. e. stop encoding
page address in handles. Instead, a small per-page structure is created
which will contain actual addresses for z3fold objects, while pointers
to fields of that structure will be used as handles.

Thus, it will be possible to change the underlying addresses to reflect
page migration.

To support migration itself, 3 callbacks will be implemented:
    1: isolation callback: z3fold_page_isolate(): try to isolate
the page by removing it from all lists. Pages scheduled for some
activity and mapped pages will not be isolated. Return true if
isolation was successful or false otherwise
    2: migration callback: z3fold_page_migrate(): re-check critical
conditions and migrate page contents to the new page provided by the
system. Returns 0 on success or negative error code otherwise
    3: putback callback: z3fold_page_putback(): put back the page
if z3fold_page_migrate() for it failed permanently (i. e. not with
-EAGAIN code).

To make sure an isolated page doesn't get freed, its kref is incremented
in z3fold_page_isolate() and decremented during post-migration
compaction, if migration was successful, or by z3fold_page_putback() in
the other case.

Since the new handle encoding scheme implies slight memory consumption
increase, better buddy search (which decreases memory consumption) is
included in this patchset.

Vitaly Wool (4):
  z3fold: introduce helper functions
  z3fold: improve compression by extending search
  z3fold: add structure for buddy handles
  z3fold: support page migration

 mm/z3fold.c |  638 ++++++++++++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 508 insertions(+), 130 deletions(-)

