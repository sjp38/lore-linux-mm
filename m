Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36BAFC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:30:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB0512080F
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:30:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB0512080F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C4B48E0002; Tue, 29 Jan 2019 13:30:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 872DC8E0001; Tue, 29 Jan 2019 13:30:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 764478E0002; Tue, 29 Jan 2019 13:30:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 574CE8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:30:01 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 4so14881993plc.5
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:30:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=owompMB1z1WOcUX0OErrBae4TG4w8JNP9G6+g5iJ/w8=;
        b=GXWvroO0RDsGORmy4rcuMn0CcGALvOsyZJ/O28YZtvZ+35hVLcBNsIXndHojDZnQPA
         ygNG3PQUg6FulKF8cQxi/d/HS1a3sK6JuwYHzSnpRRwjoCX5bgkGlxAO8xxdnUNCSpAY
         2J8dRDJFpgw4+G4Sf22UEjK652PX7BGYLfVrwKuNjDw4i/yvNe8Gw+TfoI9v/yj6Etkt
         WR7fUMLVoE7yEcz88RV96nrr/qouim19gK2jYFf1FSPQn4KZeL0Pv9xRc2F6vyh7tpDN
         dATUl3tlXYOpcCUmNjonopN6Wl+Bd3KxflAN17rinEHvElX0Z0sanqDsu/T9EBZWANjC
         4dgA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukeULvm9J3DI8TiloDLK2hzbAs3TD5loNKF78GPEJdbCArrDpQva
	kQ1FpiILI6p25bXztSJ1AX0T+G8lz/CzfopJaJqK1t78h/4m+Q1FzMrVXuYyzyASz5e4IPaf0Iy
	g/Isg3+Pk+BI8e0KiJEHzrSLE5j4rpDZrOVvxTIFDiLYLul3Yy2gedCjt4buZX8CMlA==
X-Received: by 2002:a63:6d48:: with SMTP id i69mr23724305pgc.215.1548786600862;
        Tue, 29 Jan 2019 10:30:00 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5oPMfTVLDm7bWC+CGAxdpSHlvrNfzX7L6pfWvxXkguvZgwVMzodcEzCvSxuyXcPOo8YGHG
X-Received: by 2002:a63:6d48:: with SMTP id i69mr23724269pgc.215.1548786600173;
        Tue, 29 Jan 2019 10:30:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548786600; cv=none;
        d=google.com; s=arc-20160816;
        b=0SwUTEm7XzQsApSAwIEMdiWB5ZPm0Vtuwa38KdNu246eR/OH8LLzMNdn/Oc+i6C1bA
         ejdVIBLyI/eum8iEIf4N77NgBla3yQUhFzW1RLIKU6sEQgALtoLIq9Zwns2gn3NT+oWQ
         S9yRSa8Q1zPYpLwi9kWmcFJEGuMi/Mm7kyRTOR/YjIH6ez0wTbTulUN3U1kUifKHI8ZC
         Csyw5QlRg1fNM7scMTLHiHw5d2746G+nKX15kHt01e1HdPi4BZCnGNHmA7dnNU9jwF4e
         v1oLisy8rfiJjXfN7weDt1h2yShwPLq/wWuNay+bNZkDNcmY+IQVE9+0XSyUXPnA3uFI
         3eog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=owompMB1z1WOcUX0OErrBae4TG4w8JNP9G6+g5iJ/w8=;
        b=H04K38Lxu3DrMSvFc9bZDLwP64xsHrwQiBVsxjzZb3HRbVCrTTmriR+zcnEmqmJcOp
         Ev1MfjxgD0Ta6brZ8hjBDiLW5W/v6cgt9MBYWNvje2NOvO1ZO+jSwgNXickT9rmI3fC5
         q6fjI6bpZ9VGgSR+t174e6R4Gw0AVI0GwX4nsiEzH4h15R8HDMkeViBb9qG/wuSE9WVn
         GzvVMp/YYS4C0gtGr1oCd2FG8E3eBsxouRl+mEGcIiQ+HgnayZMnRIQ/EEOA8D/vdazf
         DjjigzqCE6PCd/NNpUmLAL3tkxKWihu97emQ4vxO6t7mBTRm5lfaMTFRcUc5lFwXTnDq
         H5Rg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r25si10540144pfk.28.2019.01.29.10.29.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 10:30:00 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 8AA6A2DD5;
	Tue, 29 Jan 2019 18:29:59 +0000 (UTC)
Date: Tue, 29 Jan 2019 10:29:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org,
 mpe@ellerman.id.au, x86@kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-mm@kvack.org
Subject: Re: [PATCH V5 0/5] NestMMU pte upgrade workaround for mprotect
Message-Id: <20190129102958.844e1168972384e26b77238f@linux-foundation.org>
In-Reply-To: <20190116085035.29729-1-aneesh.kumar@linux.ibm.com>
References: <20190116085035.29729-1-aneesh.kumar@linux.ibm.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 16 Jan 2019 14:20:30 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> wrote:

> We can upgrade pte access (R -> RW transition) via mprotect. We need
> to make sure we follow the recommended pte update sequence as outlined in
> commit bd5050e38aec ("powerpc/mm/radix: Change pte relax sequence to handle nest MMU hang")
> for such updates. This patch series do that.

This series is at v5 and has no recorded review activity.  Perhaps you
cold hunt down some people to help out here?

