Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61252C28CC2
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 04:50:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24BF325D4C
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 04:50:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="JrzH8Ix8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24BF325D4C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7741F6B026F; Thu, 30 May 2019 00:50:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F5576B0272; Thu, 30 May 2019 00:50:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BC236B0273; Thu, 30 May 2019 00:50:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0D24C6B026F
	for <linux-mm@kvack.org>; Thu, 30 May 2019 00:50:27 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id r25so1506787pgv.17
        for <linux-mm@kvack.org>; Wed, 29 May 2019 21:50:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=VEMJ0wAN6f0L2PBPwqBlNkJT86VV7w23G1COjLoFnLQ=;
        b=m7rhMowa8G/Iv5XeUknzxci6CumDar7GLzJb/mIXthfovX6cdzV40adlUA7zfHNqpd
         Mu/iVuH6qac1uoO3ELQqbINMxA/LDQ9KD3gQbhNyTY2C9lELv6urJ0ll88xIUtFMr/9K
         0QFMfDrOEYhISrUjyXA3aKCm2TVQQ5tjeuJCuuZChRjGzmuYQHytcN6mCZApI41otKoN
         xhf68z0TkwsrAjQFrky+md25QLvvDis255olHYEQpH34mJ58qREE4XcR7jWOWSlvJOrz
         onqNeqWrpU8D7aHrIYvCLKc85FMbycQolkd4ju7UDeq1NoKgnHHfL6pYBfeaWMJQviKG
         pS+w==
X-Gm-Message-State: APjAAAUijz/spu8yv5fDePPDO+rSRgzdt3G7ccDyuxTuALdynRHPWBgd
	QP2uTE72yu5gaIYBhZScLtew1tnDaaCs+VROnJYQQeXTW/Dgn9vvdkJtGgFxfCJC7fdhWVbRVeB
	75DkLO9sKjsqpcvfaZ2ZEaueqCiZUJQF7PiH//bwGNHmBZEbpzzHHYiaQo/S5b4asdw==
X-Received: by 2002:a17:902:8305:: with SMTP id bd5mr1864796plb.339.1559191826660;
        Wed, 29 May 2019 21:50:26 -0700 (PDT)
X-Received: by 2002:a17:902:8305:: with SMTP id bd5mr1864767plb.339.1559191826006;
        Wed, 29 May 2019 21:50:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559191826; cv=none;
        d=google.com; s=arc-20160816;
        b=Z5GK8g+ZCAKJvKmx0WvaHWJ470kNbBgynV7/ra0AT7OA8T7M/Y2VG3xyqt+z4Mm/lh
         5w5xdiOzC8KxkUiXQO+x/Hj05KfXvbpMH69ckLdibCC7OefyfwXOS/A+USf9sKfLQ1C1
         Q/bM69z8KZbg/+6Znbh4sOCABy40w8sZ21m6unPosC9istPjq/uWDbUiVM8N2d9RzSO0
         TPduhH4qGQrsSllCRy08miJyOXl5gGfvJmhELZCHmeyBE0PbFAGZTqEkCD0CBjlw0x0d
         +64Il2lh1uJUI5T2zOGIaiihorKlq5Hoy9RaJGXoOCIruiekhdN6bTaKeNiFtAWH7k7U
         A2jA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=VEMJ0wAN6f0L2PBPwqBlNkJT86VV7w23G1COjLoFnLQ=;
        b=oW9MPfBsiFIaodlVKOkMK/85J3fsTL3Mqn6AmW3rEFgNIJYZdzwDWgSC5jirDXlu4N
         nXdxBoq71h3bWVvaDRZ1ewPhe1r9MLqz96AUiH8pTGRsCW+1HAxXghJgv6AxMCpuIBNF
         IcAmssOERjZIPOMsjRDBcWdEO2R/ueN9wDVfaqU9yp3adsB/8gZRkmSnb8Kd2ya7pngv
         A6ZNMJDsWUOn+5lm0k5cPnJ0nu9TjlNu2FZBbMwqBM0/tC+NPt+y7e6UGpj/1ROHA4Lc
         VDjn4HLfrD6OmC10ABshMp6GaIwYFFXRUYXgrnnRAEBfb/Nf7U8UUH75jOTKnJR2EVYH
         S62w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=JrzH8Ix8;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i21sor1837825pgl.11.2019.05.29.21.50.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 21:50:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=JrzH8Ix8;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=VEMJ0wAN6f0L2PBPwqBlNkJT86VV7w23G1COjLoFnLQ=;
        b=JrzH8Ix8SoZsVncsTmXV8fH3M7JjbmYl33YE8gDnA7QgHftaChETKuHHntJCjE3/aL
         FnJgOjKcGVkR+iwR5G7lFO/RxCTdU77nQkBLTFHgAteGpbTIlewLGFncxGgQOeV/xOlK
         8Qnfzv6hiXk3kB7WNns7hXrGTBCvcj64Pcb18=
X-Google-Smtp-Source: APXvYqzXBek/OrXF+N6Pci+DQWdzVuUKcdPizytLviTusXIyCypNjwhwjiK8ABKt8GhYJWDAKq7/oA==
X-Received: by 2002:a65:52c3:: with SMTP id z3mr2006961pgp.56.1559191825754;
        Wed, 29 May 2019 21:50:25 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id j13sm1331586pfh.13.2019.05.29.21.50.23
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 May 2019 21:50:24 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kees Cook <keescook@chromium.org>,
	Matthew Wilcox <willy@infradead.org>,
	Alexander Popov <alex.popov@linux.com>,
	Alexander Potapenko <glider@google.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH 0/3] mm/slab: Improved sanity checking
Date: Wed, 29 May 2019 21:50:14 -0700
Message-Id: <20190530045017.15252-1-keescook@chromium.org>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

This adds defenses against slab cache confusion (as seen in real-world
exploits[1]) and gracefully handles type confusions when trying to look
up slab caches from an arbitrary page. (Also is patch 3: new LKDTM tests
for these defenses as well as for the existing double-free detection. To
avoid possible merge conflicts, I'd prefer patch 3 went via drivers/misc,
which I will send to Greg separately, but I've included it here to help
illustrate the issues.)

-Kees

[1] https://github.com/ThomasKing2014/slides/raw/master/Building%20universal%20Android%20rooting%20with%20a%20type%20confusion%20vulnerability.pdf

Kees Cook (3):
  mm/slab: Validate cache membership under freelist hardening
  mm/slab: Sanity-check page type when looking up cache
  lkdtm/heap: Add tests for freelist hardening

 drivers/misc/lkdtm/core.c  |  5 +++
 drivers/misc/lkdtm/heap.c  | 72 ++++++++++++++++++++++++++++++++++++++
 drivers/misc/lkdtm/lkdtm.h |  5 +++
 mm/slab.c                  | 14 ++++----
 mm/slab.h                  | 29 +++++++++------
 5 files changed, 107 insertions(+), 18 deletions(-)

-- 
2.17.1

