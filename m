Return-Path: <SRS0=AeVH=PN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FEA9C43387
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 23:32:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9CCF222BB
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 23:32:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BfVlvKxU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9CCF222BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54EA48E0135; Sat,  5 Jan 2019 18:32:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FD8E8E00F9; Sat,  5 Jan 2019 18:32:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39FC78E0135; Sat,  5 Jan 2019 18:32:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E75368E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 18:31:59 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id v2so29392958plg.6
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 15:31:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=WVVkeTSU/juW8PY5Y2BUjN7xzMiqVZ2++EBgVIVpgHA=;
        b=lWgzg9GwmlqKbWcseMbM77P8Yl79m8iVhP4kIr5E+LCTyy5nNK28wKB6yRl/Y9pZy3
         KG7QwOwlp0vzEOcSiXzYQgVro872nZxkiElvRd8D1KGmdXRAWx61l0JaUDxVV2jpU0Jz
         geJsb1PxdEAaNaORlUiGr52yiSlZZi+WWctKFHXsk8kvwGuNldTKfoqBKj7HfHwYHiFK
         YLNRvWraNRW3tqlXAEXkRRo7C/2ykiBKDXhJyd1hG/RxhgM8n25khPqDeQiiQPJAUvdh
         4toV27N1KoxZTMfRep6O3yBWOeBB6pF/oXf8hTY/NhCjRun6qllqWK6bnYw3salXLcq3
         8kBw==
X-Gm-Message-State: AJcUukcFNXDzFXi7mwr5GnD1ffEK1q/Z2e9yReiJHnsrww4rN9MTHoCx
	IsNE1bfjol55iZwAsNL82FnFExlIfBtJzMosc0SWDQ3No9mwGw8gDgro2V8ylkfppcWGAnYEKgO
	78elUZpE95a3PWaf4y+RTDJvCCn3L3WMyzaCy0Dm3UZ51nymERCkPNpW5njjdYi23WRP2rUvyAf
	2KjcvFHERL9lch8fJTdP1+AHrnkyUHzgP8T5YPqb3BZq7m3ehpru6Au1DPl/EcBiDUKoOzIv0od
	sejDFf1vys0RUAg4ZnAee/bFCLrktigHkLYYmIw91McIaYInFlaM2wNjK+di8STVo1znySFCxdx
	MfJELeU9wz+zB4OPsk/KAKzfHaW34XOWvy5cqSVfP8Xm6/HF24STARWm1dfwD5rqNva9oqgDZbY
	r
X-Received: by 2002:a17:902:a40f:: with SMTP id p15mr57387759plq.286.1546731119482;
        Sat, 05 Jan 2019 15:31:59 -0800 (PST)
X-Received: by 2002:a17:902:a40f:: with SMTP id p15mr57387739plq.286.1546731118783;
        Sat, 05 Jan 2019 15:31:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546731118; cv=none;
        d=google.com; s=arc-20160816;
        b=p7xZvbf/NPYNe6k6egliSe3zkEa9LVtbisnN3lPu9WpLBkQC9PUVx0DolW0V1qJtmY
         SvIybtHfLdt+6vkDwM/cCpmm1FQrie9lyA0MXFRyzZ/83H8Axp9aqt4PlwkAKzZCmYk3
         D84Ht5fPR/7q4bjOFoN1uLazAVD1UsQnD80S4wJDKAbcGpDlrYGRFzzoQ5QZRAW5DgbE
         1tKbMx15Pkcz9NciDvYKpj7/o7wmASds10rRc6Fe8/KsJGHJ/Ta8GZ81cQipX/L0rFxe
         l4qgjxhUsvDcw1SYRPSDUxC0ng3Ork5BdDJk7V/ozOfuYoIqT2ONQ0p2gxOF5jCtIvcf
         85JA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=WVVkeTSU/juW8PY5Y2BUjN7xzMiqVZ2++EBgVIVpgHA=;
        b=C1elldFuqlqXKO1/31VPUjjL0XzJTEha4JmauIV9y3vz41SmNJLQt2Oq+iDau9eJvv
         MeLA7aZ8gKS7QdRCee8fDKZUgy/bCEHe6OMDk4WswO1J6EezulnoqxAfiPL8pyPhnV3L
         ja+1lnSf6THIeUliM/nR8HSGN4rG7T0G6EdDhOdeh/qcJgGwdONGnbTuxJzXueu9Jm22
         We3NE+nBiPvKLggo0sBTSlYvdCc4H4FIsL3xYJ6uAKEDb5RpQTkNKs0UwlaD40lfceKy
         d5daAK6ukFwDS3SPnSqToTr+sB1w07HsEGjWy1GQGENOUTk86UH/xaaQ1JcZBsiimISI
         M8pA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BfVlvKxU;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q22sor32026377pll.36.2019.01.05.15.31.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 05 Jan 2019 15:31:58 -0800 (PST)
Received-SPF: pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BfVlvKxU;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=WVVkeTSU/juW8PY5Y2BUjN7xzMiqVZ2++EBgVIVpgHA=;
        b=BfVlvKxU9jO51fanv0m57OlDnNaLYDQzsG574qPIK5kpe6RUMxhIgCx4U9JgZxMLJs
         AKvPHrGK+IV0rgitbrE0SzoZCf2ppbWWp38mpOspt+w0wWeY9tnb/YHc5ZRbHffEK3vq
         VpRQOmZLPZCdrdYZALng6Pl4JYaegsV5jgLFLX3wWmMGuF0TeW3iT2Ac7jBJN6+DBHv9
         Xh3ccvcNfo+8OkkjwmQkgLIJoQpvYsaf2zVv6IlcPxnPmoLQgl3BgWWtjOu849+2HFFm
         6W3WoOAth+b1iYgd0FcJu4WITRyxzf8fzsny3mLZADFmCqLy2eIaOsGxX76zXFgBoH2j
         puww==
X-Google-Smtp-Source: ALg8bN5DJFAMjUfnSfLk65oG7lFUmccdm4iL2N9q7fvwCblXKF5Ckw3JaASScyX/W2L79OjC3YYRvQ==
X-Received: by 2002:a17:902:264:: with SMTP id 91mr56450816plc.108.1546731118191;
        Sat, 05 Jan 2019 15:31:58 -0800 (PST)
Received: from localhost ([185.92.221.13])
        by smtp.gmail.com with ESMTPSA id x27sm115431450pfe.178.2019.01.05.15.31.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 15:31:57 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org,
	mhocko@suse.com,
	osalvador@suse.de,
	david@redhat.com,
	Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH v4] mm: remove extra drain pages on pcp list
Date: Sun,  6 Jan 2019 07:31:41 +0800
Message-Id: <20190105233141.2329-1-richard.weiyang@gmail.com>
X-Mailer: git-send-email 2.15.1
In-Reply-To: <20181221170228.10686-1-richard.weiyang@gmail.com>
References: <20181221170228.10686-1-richard.weiyang@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190105233141.7gim0kYV3mtPcpG0URNBUh_IHQ7XMaeVsgJ0eXtjJGk@z>

In current implementation, there are two places to isolate a range of
page: __offline_pages() and alloc_contig_range(). During this procedure,
it will drain pages on pcp list.

Below is a brief call flow:

  __offline_pages()/alloc_contig_range()
      start_isolate_page_range()
          set_migratetype_isolate()
              drain_all_pages()
      drain_all_pages()                 <--- A

From this snippet we can see current logic is isolate and drain pcp list
for each pageblock and drain pcp list again for the whole range.

start_isolate_page_range is responsible for isolating the given pfn
range. One part of that job is to make sure that also pages that are on
the allocator pcp lists are properly isolated. Otherwise they could be
reused and the range wouldn't be completely isolated until the memory is
freed back.  While there is no strict guarantee here because pages might
get allocated at any time before drain_all_pages is called there doesn't
seem to be any strong demand for such a guarantee.

In any case, draining is already done at the isolation level and there
is no need to do it again later by start_isolate_page_range callers
(memory hotplug and CMA allocator currently). Therefore remove pointless
draining in existing callers to make the code more clear and
functionally correct.

[mhocko@suse.com: provide a clearer changelog for the last two paragraph]

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
Acked-by: Michal Hocko <mhocko@suse.com>

---
v4:
  * adjust last two paragraph changelog from Michal's comment
v3:
  * it is not proper to rely on caller to drain pages, so keep to drain
    pages during iteration and remove the one in callers.
v2: adjust changelog with MIGRATE_ISOLATE effects for the isolated range
---
 mm/memory_hotplug.c | 1 -
 mm/page_alloc.c     | 1 -
 2 files changed, 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 6910e0eea074..d2fa6cbbb2db 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1599,7 +1599,6 @@ static int __ref __offline_pages(unsigned long start_pfn,
 
 	cond_resched();
 	lru_add_drain_all();
-	drain_all_pages(zone);
 
 	pfn = scan_movable_pages(start_pfn, end_pfn);
 	if (pfn) { /* We have movable pages */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f1edd36a1e2b..d9ee4bb3a1a7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -8041,7 +8041,6 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	 */
 
 	lru_add_drain_all();
-	drain_all_pages(cc.zone);
 
 	order = 0;
 	outer_start = start;
-- 
2.15.1

