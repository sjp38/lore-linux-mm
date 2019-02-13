Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 307FCC0044B
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 20:42:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1883222B6
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 20:42:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="vk+9afpc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1883222B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81E028E0003; Wed, 13 Feb 2019 15:42:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7CCC48E0001; Wed, 13 Feb 2019 15:42:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E38E8E0003; Wed, 13 Feb 2019 15:42:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 46DA98E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 15:42:36 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id u66so2150831ybb.15
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 12:42:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=qNCR0xN3839y7VMAmcBdO2qZgWS8pHFZK1yfc/zYXzk=;
        b=M48AmyvKRyVH111g98KUDFFzQGe4RVVpTP74QIu4SKkn2ohuymUQ3JG0TgRqJQ36Fu
         uv/FXx3eH+vS2apSXJ6ENTHLEqBHxbUocMaKobilHYvN0GkZBDcC29GYhTJ2Y+icaQ1r
         JhR6wV+fNLMekn+ivl7XmlCHXb7I1i9Wgn70e5TK6Z87ku3VIhlPhWfqyKZjxKAKoBaz
         H1Dgglv9IjnZmlS3ud7fW6ZJm3/7QlIb62+1pwcK9czpbm98kZ0H0j3mZxSfTiV0hTh6
         8FtqoLsfhZ9f4aEzXhUuA4mgjSPYtnu1mrlortMVGLjvhZQBgWBhd+9eGZe7VstQaOFN
         ERlw==
X-Gm-Message-State: AHQUAuaTlTBo9KPBMXzx+qagdNDlqeet4/rJkvuOb91fXwf9c8SFVK6w
	KqhS3Mx3E+kIFbfC04PT4E3OgQVWG+keS38IEoYTyeiSbJQ7TalFmHskwiIPndmtVQS1GpV1eU7
	xnOhBUnMBAhUvOEEipROeB6+GOrKQbB2oL2HvPYFp/9CDqni+q/0ZbcoQ8MDrxU0HA7LoqtgIps
	Bs4nKR46PsisIXof/W8393wn96eTHDot17uBnCRcnVQzGic5dUmbY20a/70zQyDxrI68dEhlKwq
	dEwtNVbclqSZL1XtEMjqYl87uezGeUPyX6VHBve6uSs/YJmxeBzIAx12M63RmyzT7034qkvHds9
	LbAGDyNDB//ybNOVZrMUxS4RxFw/sk7OXfs5nLalV2M/WnNbkX7JWfcHJ+fEDEdrIp7FbOfaxbE
	qDQ5e9LqQicPeJ42kTTtX9/hKPEkFSxYPFUoOJkoYwwljWIvO2dP0e/dYNZgZhTK9680nbf9TIb
	+P1RHrTMk7gLsKJVmXELmMXG6nkwgkE2g2kWGNYy/eTj8CVuVjNffkQ52x1Wu8wqv70/7L0hfz/
	QAjLC7kP+cyhNOfhchlgdtFBVKFF14IYRl49eYjdtcnsTCsAoMerBG0dwNyQRA4xiIBcQfcU2x9
	khxb0jRe0u2xyTqurCntduuLrlq0dtqH3UAmg4/M0rD6Xp2koXbF1gV+NurXFRbH9OI/HJ8Iup5
	N
X-Received: by 2002:a81:2548:: with SMTP id l69mr6400212ywl.397.1550090555986;
        Wed, 13 Feb 2019 12:42:35 -0800 (PST)
X-Received: by 2002:a81:2548:: with SMTP id l69mr6400177ywl.397.1550090555342;
        Wed, 13 Feb 2019 12:42:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550090555; cv=none;
        d=google.com; s=arc-20160816;
        b=i6sNX3SBh3vadC7LaGryBSxLkfDjZ+eaG/VnyxdJzcsgYhX6XDyR8whgN+1b0k9fHd
         lBr6MefCAmX1RCuX7rJTKPZ2WJQiDqpAJQbSYS5pB7dP1Mv0d9CnXD8ODcurz1TUorJZ
         4racNuSTJtZ75DYMKKl6h7iBS8KTanyDkm+nZTlsJylj76QJ7z1aT9Pia+lDryzwbTVP
         t0Q3VVLq83I+uGqtz4OsUOI4Xaj2h2LXHJYPwLGN3RaryuDZdkRy79u1bcGoBs1X6p/4
         NvUhGM71bCsiJvpGi5POzrFuetydMqlpkDY+R+ECGTf46SecgtKKjL8I45ZKpROhAV1C
         guqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=qNCR0xN3839y7VMAmcBdO2qZgWS8pHFZK1yfc/zYXzk=;
        b=p/BN/PiqmBno1C/nXFg4k4C8jAA4ctozbwsv/DcR+XLUtG+mqaICWAdrBlOlgeib4b
         uDNAbJFPSAnf86j3xcXWkmLV2d+vcC7xqSBz4Y8r5rschXfOdRKOKUAsJ9HjnV7PdgQS
         x2G/coUwqar7wJ6Y+Z3CHYY0Oj6lDKTvrozTZ0Wyi0PClDL/Ghtn6C/nExtBnkE6ha2j
         ojrMvcmgucGFXmD75a1zHv397xj6NuKQtxvXdTfdCurf1H4A7m3/2QReJl/rgdKI8Kmm
         vD9C1M1cxlEwUekRZXcR3gWXIfr2cJBbO3cBZL36p68QFyRXa6n0rjTxczLi/7eMx/xX
         3HPA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vk+9afpc;
       spf=pass (google.com: domain of 3o4fkxaukclghyllfemmejc.amkjglsv-kkityai.mpe@flex--jannh.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3O4FkXAUKCLghYllfemmejc.amkjglsv-kkitYai.mpe@flex--jannh.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id z1sor55656ywl.213.2019.02.13.12.42.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 12:42:35 -0800 (PST)
Received-SPF: pass (google.com: domain of 3o4fkxaukclghyllfemmejc.amkjglsv-kkityai.mpe@flex--jannh.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vk+9afpc;
       spf=pass (google.com: domain of 3o4fkxaukclghyllfemmejc.amkjglsv-kkityai.mpe@flex--jannh.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3O4FkXAUKCLghYllfemmejc.amkjglsv-kkitYai.mpe@flex--jannh.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=qNCR0xN3839y7VMAmcBdO2qZgWS8pHFZK1yfc/zYXzk=;
        b=vk+9afpcYaiUM95aJA3YpkniHaAPKIKCIB0/xfPAYsnuF7/YNMPbNb4k5yafb8q/hg
         dVvuTWNKWxUYfWb8F6n2t+L5vbcXbDUy3v0W2SR65b+SIBSo/aW1YG0v4KZnPP49Yw8i
         4RdXH8htDGSG2dUmswH0gKObCDVSIPoaKTXzxGC2+quA8rx4wmm1VU1/SPLn6lViG2bR
         YnuQuZSJVMNhR4T6L/wKH9RF32kEWhfaJ6A0OACNv8zBV3ni012T46sxjKfCeLhRCLy3
         B9ecidL7VHAcArqfULSdG2dD3UjWr73rgCyOjB4szjIgotWbzRazwSg1rn3un1gjiHA8
         R3Vg==
X-Google-Smtp-Source: AHgI3IYGHa4+7qE44erSpdyH7XPkwQLF/QTlE5/7wNbNcq+pC/rZo8F6iVN+yBzCSGsts8+B5GUGhLRnOw==
X-Received: by 2002:a81:e50:: with SMTP id 77mr19924ywo.20.1550090555029; Wed,
 13 Feb 2019 12:42:35 -0800 (PST)
Date: Wed, 13 Feb 2019 21:41:57 +0100
Message-Id: <20190213204157.12570-1-jannh@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.20.1.791.gb4d0f1c61a-goog
Subject: [PATCH] mm: page_alloc: fix ref bias in page_frag_alloc() for 1-byte allocs
From: Jann Horn <jannh@google.com>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, jannh@google.com
Cc: linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Pavel Tatashin <pavel.tatashin@microsoft.com>, 
	Oscar Salvador <osalvador@suse.de>, Mel Gorman <mgorman@techsingularity.net>, 
	Aaron Lu <aaron.lu@intel.com>, netdev@vger.kernel.org, 
	Alexander Duyck <alexander.h.duyck@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The basic idea behind ->pagecnt_bias is: If we pre-allocate the maximum
number of references that we might need to create in the fastpath later,
the bump-allocation fastpath only has to modify the non-atomic bias value
that tracks the number of extra references we hold instead of the atomic
refcount. The maximum number of allocations we can serve (under the
assumption that no allocation is made with size 0) is nc->size, so that's
the bias used.

However, even when all memory in the allocation has been given away, a
reference to the page is still held; and in the `offset < 0` slowpath, the
page may be reused if everyone else has dropped their references.
This means that the necessary number of references is actually
`nc->size+1`.

Luckily, from a quick grep, it looks like the only path that can call
page_frag_alloc(fragsz=1) is TAP with the IFF_NAPI_FRAGS flag, which
requires CAP_NET_ADMIN in the init namespace and is only intended to be
used for kernel testing and fuzzing.

To test for this issue, put a `WARN_ON(page_ref_count(page) == 0)` in the
`offset < 0` path, below the virt_to_page() call, and then repeatedly call
writev() on a TAP device with IFF_TAP|IFF_NO_PI|IFF_NAPI_FRAGS|IFF_NAPI,
with a vector consisting of 15 elements containing 1 byte each.

Cc: stable@vger.kernel.org
Signed-off-by: Jann Horn <jannh@google.com>
---
 mm/page_alloc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 35fdde041f5c..46285d28e43b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4675,11 +4675,11 @@ void *page_frag_alloc(struct page_frag_cache *nc,
 		/* Even if we own the page, we do not use atomic_set().
 		 * This would break get_page_unless_zero() users.
 		 */
-		page_ref_add(page, size - 1);
+		page_ref_add(page, size);
 
 		/* reset page count bias and offset to start of new frag */
 		nc->pfmemalloc = page_is_pfmemalloc(page);
-		nc->pagecnt_bias = size;
+		nc->pagecnt_bias = size + 1;
 		nc->offset = size;
 	}
 
@@ -4695,10 +4695,10 @@ void *page_frag_alloc(struct page_frag_cache *nc,
 		size = nc->size;
 #endif
 		/* OK, page count is 0, we can safely set it */
-		set_page_count(page, size);
+		set_page_count(page, size + 1);
 
 		/* reset page count bias and offset to start of new frag */
-		nc->pagecnt_bias = size;
+		nc->pagecnt_bias = size + 1;
 		offset = size - fragsz;
 	}
 
-- 
2.20.1.791.gb4d0f1c61a-goog

