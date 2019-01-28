Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB0F6C282CD
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 22:53:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 925C22177E
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 22:53:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 925C22177E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 139608E0003; Mon, 28 Jan 2019 17:53:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0EA7E8E0001; Mon, 28 Jan 2019 17:53:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 000878E0003; Mon, 28 Jan 2019 17:53:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C1B838E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 17:53:08 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id d71so12558006pgc.1
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 14:53:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=IxZ9dHPB4JklrRQa4Bzspi6QA6TSSjMHaLsWXo8dHgs=;
        b=mo1othPd+wdfn1WSl1E8aAHdzbYRVKAlvHVprsd5aRvtPNfYSAjwUAwDE8XOHp4XvU
         dYldu170VZTiFDZFfpgUe7tKiMluvx1dgIqrlorz51b0C0I3rWdVipMCK8q3FiftcK0D
         hFCLWxO+X9XixvlHgI4pC8omtSWKOJd6flX4OR5mm5XdXire9u6ypgscv4/6LYk5Wm0B
         QY1Ihoo4hm470eu0M4H5pD0IdAZKlvm26bHRRM+uq/y1YCapXNMszh0knwx8eXHSOJ76
         e4y39swHO6zk/zjBagMqw/ufPP5Sq7vw8b2lAXFtrjPPREchK1X7HgW04ylJ/pI9Un9U
         o8aw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukc/1Xabsz9yQ1fxheML/8TwG/DvMLJnk9dk+1kQOH8SI1JyIXpa
	JhQdrmSp+szFZq8xyRGbvQTucJ5AsuinVm1qveUMb7wAGw8dgO9WsZgxINQ1f5f+wlTFvnNTTTE
	pJfmdzhRCfOHLuOWaDDGBl6xF0vxgPqByi5E8ZVCMRleXIy0gUeXo2IHaxySE6yNa3w==
X-Received: by 2002:a17:902:5a4d:: with SMTP id f13mr24343495plm.49.1548715988448;
        Mon, 28 Jan 2019 14:53:08 -0800 (PST)
X-Google-Smtp-Source: ALg8bN48yhwA4FqaRa0J3Bo+Q8MTNWu4rJym7MBbOMtzgnYdp0xmMC+aWPWH46hDTqz32PERwGKT
X-Received: by 2002:a17:902:5a4d:: with SMTP id f13mr24343465plm.49.1548715987841;
        Mon, 28 Jan 2019 14:53:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548715987; cv=none;
        d=google.com; s=arc-20160816;
        b=XZ0a+WTNnHVomiwpKErfWKjAeakU1n7UZ/wsJRRnwZAsDVBahMgl6KRHxXoE1OJHpP
         7MHvK92KjhqLlARgVvRUzGYQGtJorEQk0BSNkEQTOhb3NePLW87NpwmoCi0OefDUuq1a
         hz4NPc5CX1lixJ6H3+csZUvFknD5ZQ8Qmj80TCKxPOj01JlOJ9GnhvflyM+aftq8Y1aS
         pi+LWMsdIk9UEHku2Gj13QTVRKcZpvhvrmXXT0A8sLZRtRV10ZHfA40T+LIZF9/hBYq7
         3x/yj5oQjerZsRTcawGPqT7nc8KTDYzlQyW/h6WHCH/CtCgDUASoWNovLG35mr7JgjwP
         Kf8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=IxZ9dHPB4JklrRQa4Bzspi6QA6TSSjMHaLsWXo8dHgs=;
        b=aXb5yTo8u0J3SRQza92UBFbIIggASFgXU1qIle3NcgjzPkH/jjCq3/IgzBH3CIe3El
         hqMZFCYz2m9TMTXqNKnlosQ+1StGGUlteag4V8Shqvu+Enbj5aVfDh3DUX5Hj21NKgmW
         iQsbckreal5v9letHCttvrJnw0TxdeQ6GiUtitFDfgAcgWJ67fmgdMyqCd117V6aRcYt
         /K4BJMditAlR5lsPSB0v8xMVJfSMySRZXBrynMGxU6gBbmVxnoIMAfUnAbGSFBR62o07
         Q53zU38xTHx5gNT4eqd+8wtdFu/Ax+dF4ALkEcF5yPaBIzNmbMIW3TtaFapI7Kgqej4R
         hZEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t75si33950150pfa.170.2019.01.28.14.53.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 14:53:07 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 84FF11DFA;
	Mon, 28 Jan 2019 22:53:05 +0000 (UTC)
Date: Mon, 28 Jan 2019 14:53:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com,
 david@redhat.com
Subject: Re: [PATCH] mm,memory_hotplug: Fix scan_movable_pages for gigantic
 hugepages
Message-Id: <20190128145304.19cfbc3bb1345d4a05fbd75e@linux-foundation.org>
In-Reply-To: <20190122154407.18417-1-osalvador@suse.de>
References: <20190122154407.18417-1-osalvador@suse.de>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 22 Jan 2019 16:44:07 +0100 Oscar Salvador <osalvador@suse.de> wrote:

> This is the same sort of error we saw in [1].

I'll replace "[1]" with 17e2e7d7e1b83 ("mm, page_alloc: fix
has_unmovable_pages for HugePages").

> Signed-off-by: Oscar Salvador <osalvador@suse.de>

And I'll add cc:stable.

