Return-Path: <SRS0=oA8h=PB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F392CC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 13:18:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE4E721850
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 13:18:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TD45kp+T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE4E721850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60C848E0005; Mon, 24 Dec 2018 08:18:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BC8D8E0001; Mon, 24 Dec 2018 08:18:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4AC178E0005; Mon, 24 Dec 2018 08:18:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 09AA38E0001
	for <linux-mm@kvack.org>; Mon, 24 Dec 2018 08:18:33 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id d3so10746123pgv.23
        for <linux-mm@kvack.org>; Mon, 24 Dec 2018 05:18:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=pFA19XQqRIOonXczeaJc1JMDfCxsc2SPHw+vTN0jttk=;
        b=ZIM5MSDax33D6hZ8+4fI9xIIJicRnVk6KFCcW2n1IZPq4zDrgJI6hgvx1mW5SD4afX
         jo9o70CrOxGISQKAZSZx8FQkgg751nvHTNokNRlexvwDbGOFoxNOLfpNatKzxpyDZxlX
         kz6mAqbz+J9cux0GlTT1hUeUeOUnuUzw5pXi/OeLrpBiba3m+/MPfEMX4O08c/EcqVmK
         Xg6oNBWlQBb2Z+nXUD+c3MFgcPjRVCk3C+2c4Vfw1BTb6coMw9as4sW/ZFZvb7ypPWEB
         EHFpizI+8QWcmeEvwsEFwNeYIBD9JTusy8ufAIGvtYm7bZbQ7R+KfkpxzKrWR0BSFVf9
         3pTQ==
X-Gm-Message-State: AJcUukditKsTub9U1KC66+9VmwYJwMzxYuOXfJflE+OFt/y5Dh5SuVVy
	KysYajNBZvxU3fFOuZxvfhE9lSvm31n+1rAQJkPIdIE07sWHivvFLsipAtlkT6QcPV+p3y35anU
	njHNh2PKQDiBFKhsfbjAD7mDIyUK+V7yAxFc3ONJ+WVCVv/mrNMNRSVlkSkvkOiz3TLl+uFu4I1
	NLjYqkc7k6gIz9mGL5w93xdB4aXcxRtIzpGTdFdq0I3cdi5wVSLwEerlqiNfeTXArs5C7GsCFVW
	A47R8v/BSadXbBZUVc37GxdlcIJLQ3bRpvOIT6dRx0nxoMyGzf2bfFX3M2vt7uY2Iu/EyzmBkUu
	n6RwxhSlnJ3QXLRn/uoPrB76ozAd+2fOQC9yZgTTPrjfRUcbHEiTIyFu8dPZfR81Pd/OLGsSbjS
	x
X-Received: by 2002:a62:1212:: with SMTP id a18mr13484982pfj.217.1545657512520;
        Mon, 24 Dec 2018 05:18:32 -0800 (PST)
X-Received: by 2002:a62:1212:: with SMTP id a18mr13484931pfj.217.1545657511800;
        Mon, 24 Dec 2018 05:18:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545657511; cv=none;
        d=google.com; s=arc-20160816;
        b=B7sgn1E9N9vEsVi0O13ZbXE70s19fE5hyzsoauXeqq9d4EpjkfCXb5OKvIu20YDKJV
         QZQ5RiETy9l1qqLu3XoHIz3S/QOPldPCBuIvAAXX4hvaZEdFh8FGAUDdb2QkN6cOFns4
         6RVxgfEA2+vR73vi4zA+feDFzh6edroADzHOIniPRQce09dbSUeZC1t7doQMUiQPJLIo
         97OVryQWA82RY75SWc9cqS9Xbep4EIUB3gjC/5OHXppAyhKEjajcIS27Bz7Mq+My44tC
         J98J71BJrWvGQ72Gkh+Zs4VOsgDmxWBVG+/WB1kp2IaoqjSym6mgnIO3rIj9MPJEWAcK
         mOxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=pFA19XQqRIOonXczeaJc1JMDfCxsc2SPHw+vTN0jttk=;
        b=xJHHYS6xvhXPuqJkndVF2XCZeOq2Ghe2FmYAvUSKtpT3M8U6VOIAL8YJyNjCj8lMvK
         jW1LdZGvXo6Nvl1BAiQ4TfwBJQoDk+dz1e6x0DXVGermVcmM7z2wfCnrj+aGU48WxJNi
         77o6rEJRdjLdSZM8ui/lDrK1d+703NgPUtBRoJ8NF6rj7SYpa9uuXSjpi8/pwxwbzIFO
         L3EPUfGpFntwMabkxbynAxXsjNk+SgRcNsMgwUkjfxIYkWr1fFRbButrc+f67jqoeerS
         5PADUApKo4YQm7LsRDJap7+LA+/B9eo2uS+4kuv+6H9BHd+GY9Hl6szAGz3BrAbc0a58
         saHw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TD45kp+T;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y8sor48149385plr.42.2018.12.24.05.18.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Dec 2018 05:18:31 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TD45kp+T;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=pFA19XQqRIOonXczeaJc1JMDfCxsc2SPHw+vTN0jttk=;
        b=TD45kp+Toiz0zyzHxRUMulEByoStvt6ALI4SRmA3r7+UR6vf1Fv9a5JZlAX5TD1VXN
         uySrs+KKlKj6AILhcxkzINzdziuX5bcL2X/eIZv1ApoknaBxtC0iQ+dScI6QyWwvgG9A
         KWU48g1Gzfc82fpG+paZm07hduVR+l1LiSnXUyIrBafxPSynW7LPdl8bhdzMYq/4AeCK
         OdyaoSSvevrLr/uRnMFcP5ABeJIURBQ3dcRXX9+4yECKcyCXvhymfBQVwrUDrubsv/sn
         T+AXjPEGV5m+ZsjztLaTPuh8na33XnafrsLskOheO2KRZnyIBRfgSSuM6Pn95LfGvPeR
         06SA==
X-Google-Smtp-Source: ALg8bN4XK5L89IhWFZWeXxyCo+XDDhmG6v7dUoEX5qNfkascP5MGDznUdyua+AHQOE+3TD6j5/G3fA==
X-Received: by 2002:a17:902:8ec8:: with SMTP id x8mr13070446plo.210.1545657511512;
        Mon, 24 Dec 2018 05:18:31 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([106.51.18.181])
        by smtp.gmail.com with ESMTPSA id k14sm58126547pgs.52.2018.12.24.05.18.30
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Dec 2018 05:18:30 -0800 (PST)
Date: Mon, 24 Dec 2018 18:52:27 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	stefanr@s5r6.in-berlin.de, linux@armlinux.org.uk,
	robin.murphy@arm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	linux1394-devel@lists.sourceforge.net
Subject: [PATCH v5 3/9] drivers/firewire/core-iso.c: Convert to use
 vm_insert_range
Message-ID: <20181224132227.GA22096@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181224132227.89ME5RwzBhFI6ey_dW2j1PfnbSM-zI44xoUJTeWeIaw@z>

Convert to use vm_insert_range to map range of kernel memory
to user vma.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Matthew Wilcox <willy@infradead.org>
---
 drivers/firewire/core-iso.c | 15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

diff --git a/drivers/firewire/core-iso.c b/drivers/firewire/core-iso.c
index 35e784c..7bf28bb 100644
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
+	return vm_insert_range(vma, vma->vm_start, buffer->pages,
+				buffer->page_count);
 }
 
 void fw_iso_buffer_destroy(struct fw_iso_buffer *buffer,
-- 
1.9.1

