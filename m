Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 779E5C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:59:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 333E320836
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:59:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HHXHCXDq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 333E320836
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D1C698E0004; Wed, 13 Feb 2019 08:59:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCC208E0002; Wed, 13 Feb 2019 08:59:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBAC88E0004; Wed, 13 Feb 2019 08:59:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7AC8C8E0002
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:59:14 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id cg18so1782171plb.1
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:59:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=naB3KMuHNTCaDD6/Z64EGJGrk7XQ7GW1pzVQ9Q3Vf6s=;
        b=nOSSudmnAC1fe5UYUElrmr//S5qbAuN8VLodISz1RKSnTsfZUl3JYQ8aPZcy2ZbEUS
         K7YR37qqNcHyzqyNXUBLs5+6MoVE1gZJ/pwE3GQ84oMaNnKfH/mqOp/CJb6v6P8LLeWi
         7hhOkrQTuZ/JO46DRCh2PVcpbD2//vtsLvba5kg4W3DHeOZRb6Hg/IV69mhz/nxYhRzt
         0DFUV67onq3YRtByOR30Lf8RuJOpSFSKcrxjaMGnzSQafDrOk8+MiC/9hVvGH6bT6j1j
         oCvfVZfD0I6YlLO+ZWMS7fyQKRYgh0sxhA6EWpq3S7z19y9+P9/2bflCIOowfS7vYhJA
         zbZw==
X-Gm-Message-State: AHQUAubKcyDUCkt7F6D9ybv6M8+BxhBmBO/aOmK5JBnXgd9Ah4gcr2ck
	PtXqB+f1/Bbz2o0SUVxEutQ1Wp5nEOv63biJbMexwiiLbUP6O0z6BXfoQrSeXWqJNKRcr7cwdTn
	8/KAt4yXVWnBwkPta3zXY4wM2bXvBxy9DEvrDKziGuOecIzIos3oDSgyeV3lWdPgja8BLL7vZrX
	GyEk6t9k42qGin5BKohJvG0pmHQVxvIknQUp42Cz/bxpGxd+acl9BG6gJvztGRDPLUMbqSJE9hL
	byj0uC76nxknOnZksYi7n2qGbfW0xRjsfQVDoxnYK2wXlEyuHbFO8ba+mhZRoF8q74Z6miKfxf/
	EJviTd9QEr3qfjf/Ne3oFkUHylWakZu9/XjWn6C8bSzBgOX81yqFdxK7bywuIGSTa2JBfZS84VB
	2
X-Received: by 2002:a17:902:8a8a:: with SMTP id p10mr720392plo.50.1550066354183;
        Wed, 13 Feb 2019 05:59:14 -0800 (PST)
X-Received: by 2002:a17:902:8a8a:: with SMTP id p10mr720362plo.50.1550066353572;
        Wed, 13 Feb 2019 05:59:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550066353; cv=none;
        d=google.com; s=arc-20160816;
        b=lY4ZAB3vJqWub3Jg9ojeTGXqK2RoxfzWmcLwp4qB/MsDYDylF4fpenfgGBbMVYKa1A
         P8y37Hr3wNTXL5d6d2tLI3juyUpIMmTf7eeCA59UR5py/5NPnQIQP0AyH/eX0vS9SdXZ
         jlj8+WoM8M6lofCndMY0lnwBtZKQW2SLz1kGxNHATUDnoTR6wd0zcRom/cye5+MT76TH
         G5vMn6w0csqczrXcS67kV9xvl2Q2tt3h3sLBnG+DsATfxRDn7GZ3EorpsC72o4GVN2qY
         kGCHzXiqBqbgDhENy7HUBhovBt/+tKXD9qSsJDgjMPWpj6Y6bQpXeJwv9DmvPie6MXIU
         +26Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=naB3KMuHNTCaDD6/Z64EGJGrk7XQ7GW1pzVQ9Q3Vf6s=;
        b=T9vN6YLvvn5R20fvHiZQQCmWh14wmnyCUbcbwyqxdTf7rhggRdEmVMJrbsD7m7T8TB
         cFdjRQvILHUv7IAzckJReM5CSYGw3HlE6V/LqwkBT8l2Fs0dkgck1Ud46zf5Yu0I4/vu
         35QS1cHDoZDC/VAMHC6Lu7yowTviIazx4LQlClVkXeS6dxF1G0bD+mtmxhYvcPpqQPpA
         OirX90ialwKGwd8IGpmfZFk8GaSxCs9Agj44YFnSYatHUxUe/RtoCByHvq5To7yyi8DE
         mfRXr89FU5qiRUQTu9nmS+2QR0QlAqmyrrbQUOyysKFZ90hxUopWGHCQon60m8Xt20Fl
         FA2g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HHXHCXDq;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bc12sor23914773plb.37.2019.02.13.05.59.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 05:59:13 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HHXHCXDq;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=naB3KMuHNTCaDD6/Z64EGJGrk7XQ7GW1pzVQ9Q3Vf6s=;
        b=HHXHCXDqjrbjv9vKNBt9+7oEqMLimW2KaqFOqXNr/HA7rhmmEUFkNlY/u1NnQgZNbH
         +CDaalSV78Qcw6kY5OQUhGjsfrH+by8CS5/gJGu3VNqes+WPN1dRNmLxWbGIfZdm7c8f
         15gEiqZIi9KcnTmJeiE0/uvejDFQlK3pGLnh1YPOu2dqmZ2OMrKZkGjN68Mg+yf3YDmN
         Ttkvg6nMsBdyaGH/uB7E4ipzK3thPAR0ZqymOfIw+XSoxI5PHoZerSNybOokoRu9/Y+c
         A3BYZAAsc1mpb1sa8omgtYbiZEsojeWq9nmMQjwKjC3dkqWy7hcLdNXjZUfWSeiI7qP3
         8jAA==
X-Google-Smtp-Source: AHgI3IYElBePFcn4s9J3Tqwya9pPVWfxESsTKj0N4GiKgmRE7PyggN/XPQLDEGJiVcCZzaxyw7jtWA==
X-Received: by 2002:a17:902:724c:: with SMTP id c12mr673309pll.144.1550066353286;
        Wed, 13 Feb 2019 05:59:13 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([49.207.48.54])
        by smtp.gmail.com with ESMTPSA id a15sm24035107pgd.4.2019.02.13.05.59.11
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 13 Feb 2019 05:59:12 -0800 (PST)
Date: Wed, 13 Feb 2019 19:33:30 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	stefanr@s5r6.in-berlin.de, linux@armlinux.org.uk,
	robin.murphy@arm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	linux1394-devel@lists.sourceforge.net
Subject: [PATCH v3 3/9] drivers/firewire/core-iso.c: Convert to use
 vm_map_pages_zero()
Message-ID: <20190213140330.GA21993@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Convert to use vm_map_pages_zero() to map range of kernel memory
to user vma.

This driver has ignored vm_pgoff and mapped the entire pages. We
could later "fix" these drivers to behave according to the normal
vm_pgoff offsetting simply by removing the _zero suffix on the
function name and if that causes regressions, it gives us an easy
way to revert.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 drivers/firewire/core-iso.c | 15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

diff --git a/drivers/firewire/core-iso.c b/drivers/firewire/core-iso.c
index 35e784c..5414eb1 100644
--- a/drivers/firewire/core-iso.c
+++ b/drivers/firewire/core-iso.c
@@ -107,19 +107,8 @@ int fw_iso_buffer_init(struct fw_iso_buffer *buffer, struct fw_card *card,
 int fw_iso_buffer_map_vma(struct fw_iso_buffer *buffer,
 			  struct vm_area_struct *vma)
 {
-	unsigned long uaddr;
-	int i, err;
-
-	uaddr = vma->vm_start;
-	for (i = 0; i < buffer->page_count; i++) {
-		err = vm_insert_page(vma, uaddr, buffer->pages[i]);
-		if (err)
-			return err;
-
-		uaddr += PAGE_SIZE;
-	}
-
-	return 0;
+	return vm_map_pages_zero(vma, buffer->pages,
+					buffer->page_count);
 }
 
 void fw_iso_buffer_destroy(struct fw_iso_buffer *buffer,
-- 
1.9.1

