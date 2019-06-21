Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0112C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 10:15:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 945D8208CA
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 10:15:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gdx1TwVY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 945D8208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5CAB6B0005; Fri, 21 Jun 2019 06:15:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E0D708E0002; Fri, 21 Jun 2019 06:15:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFCC78E0001; Fri, 21 Jun 2019 06:15:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 993896B0005
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 06:15:10 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id a21so3809876pgh.11
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 03:15:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=omigN5ajY8g9C+WiMqPUHrtzjvhSN3jrdk+GcBeClaQ=;
        b=dQdZwpKcHVgEZgzy2HCFAnmQRnY+TVPnXs+yZ6QBAha/thUJ0X7ZtXDJGj47M15428
         3kihxwr+PUdiEA+VAaX1xPSWvmfy5wQSDSyNaW6UFEv3vi9Wp9URV8Ne4h+eNMWDw1WV
         YmKb++B81bwiD2+Jb9/U5DhQ6djujFTMHI5YglAXNISoojXSI8Ky+7M/YJslSxroQeG6
         RgENIcO7XFHwQZ+WMfjsNutbQ/Qi4ouqzNreMerX1kq1yp7+tjZh8FQm5gnfaXepaJ9q
         +qx/lRnjcUaFKoN/uuXelPu9cSudN0hScvicq8fmVv3QAGNGjlxenH1uNm6o0TUMe7Ue
         45Ww==
X-Gm-Message-State: APjAAAVU1EhgHc01zBXnB3xfvOhrdJ4WB7PbZZWLsZlYxpT52knOSEJe
	z7fGdir1g3w6jgoeuvq1KKZgYEw0fl3nqUj/Pnwb4syHueJGZjUjdocCzYyOLyO16npIRZdzawb
	BHj8aIopKT3N6DWZUhAIaImo7GsD1iNsyKg+tJjuPOgmSHvhm3j2oKRh7vmmdksJaGQ==
X-Received: by 2002:a17:90a:23ce:: with SMTP id g72mr5615945pje.77.1561112110197;
        Fri, 21 Jun 2019 03:15:10 -0700 (PDT)
X-Received: by 2002:a17:90a:23ce:: with SMTP id g72mr5615857pje.77.1561112109338;
        Fri, 21 Jun 2019 03:15:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561112109; cv=none;
        d=google.com; s=arc-20160816;
        b=fxjxAIOoZheZpDuBtFBA4FYzS2PUNcM5HEa3kQ/J7papBdbtsJzzQvRNDlyOOv+vno
         Qwh8kffVKjln4ymaND2zwJoDPZwDcq5JFXoMQ3AdN+zqmRQmUls9kfa7mcMRL7omkaMv
         lUNZ3APEVbgvVyrSK/DWemyg9i8AkO9rGEbfYceLZO1BaB5uCLsw62uQ0As2i91dzN8t
         b4E8AwjabIMRwzWEcBez/57eNgct6JtoQAsapd8YiX7Vx0HtY/jiPqGlAaklsrjbVTAm
         syZByvMWRFjrnvvbOBnjhOBPr1Vt6Yi8LKsvKiqeLRYqB+p+JYy+/KOqe2QEefsEOyNk
         w+GQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=omigN5ajY8g9C+WiMqPUHrtzjvhSN3jrdk+GcBeClaQ=;
        b=b+iug9+l42yk0JU3bO/uvC/o04ZM2yNWxE0u7DN5Izz24OGaVbbfeYbrRlGD3Py500
         gow266B3KdZJqEOJp8PbwhJfedfhiETtH+arUaIs8SPvWr9imFvN7Eyuo8a7UzjREBBK
         lCj5rXHaAKDHiXXqjJtZdp4prOGXZzCLb4Z02kl17XSgb4IwPPjC9bNEk2pDU7H/nfsX
         VjitzsteYAezsj4U4+LGB+EnLYVDkxOd6D/OrsWg8f7CrO+aEZCt2kwYWiZpSUMXLpwY
         Atx9F5Nu/T01Jz83IPJ2J7hQsbqxtKq0zdS2tp3fsMus0sl0Dn++FIE+g/rGXvqPWQD8
         sMZA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gdx1TwVY;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g9sor3374093pjs.21.2019.06.21.03.15.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 03:15:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gdx1TwVY;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=omigN5ajY8g9C+WiMqPUHrtzjvhSN3jrdk+GcBeClaQ=;
        b=gdx1TwVY6LIs/GFjMZIwR8WwcTw8eXl4NBeEp6zd5/IawPNXRg6cgSSSSDW5Zub6ye
         5q3WxEf0faIEu7A3A2fwO8I6Y5sxH+TQ5e91So4Upf+B5mfEzRTaGZw5CxgnUmraIrQ4
         YWPIkosbiSlhan5a/eiTaSIiDo7exxvWEgzk+jVkWlWojSpQMFvdQtCcy6z8QKjxY8zR
         l5FdPriTjeN3w4QJz7077X8WNnpnLl9yFi0iJra0fbSwZYgKAaXvU7V/Y6kMoTt9stn4
         BL4AwsrOV0qrnz47FTmrUe2Ig0HMTF1j43d3en1rrjrzHsPqkaXBEa3/K7VywUQSW28T
         4LOw==
X-Google-Smtp-Source: APXvYqy39aemjYoq3HvNeAOcUqTD1+5iDWNmkZKj6KGDIpKBP+efcToW6qleb66NoRJpmWBcEVq6pA==
X-Received: by 2002:a17:90a:b903:: with SMTP id p3mr5514645pjr.79.1561112109008;
        Fri, 21 Jun 2019 03:15:09 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id c9sm2578763pfn.3.2019.06.21.03.15.05
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 03:15:08 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org,
	ktkhai@virtuozzo.com,
	mhocko@suse.com,
	hannes@cmpxchg.org,
	vdavydov.dev@gmail.com,
	mgorman@techsingularity.net
Cc: linux-mm@kvack.org,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH 0/2] mm/vmscan: calculate reclaimed slab in all reclaim paths
Date: Fri, 21 Jun 2019 18:14:44 +0800
Message-Id: <1561112086-6169-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patchset is to fix the issues in doing shrink slab.

There're six different reclaim paths by now,
- kswapd reclaim path
- node reclaim path
- hibernate preallocate memory reclaim path
- direct reclaim path
- memcg reclaim path
- memcg softlimit reclaim path

The slab caches reclaimed in these paths are only calculated in the above
three paths.
The issues are detailed explained in patch #2.
We should calculate the reclaimed slab caches in every reclaim path.
In order to do it, the struct reclaim_state is placed into the
struct shrink_control.

In node reclaim path, there'is another issue about shrinking slab,
which is adressed in another patch[1].


[1] mm/vmscan: shrink slab in node reclaim
https://lore.kernel.org/linux-mm/1559874946-22960-1-git-send-email-laoar.shao@gmail.com/

Yafang Shao (2):
  mm/vmscan: add a new member reclaim_state in struct shrink_control
  mm/vmscan: calculate reclaimed slab caches in all reclaim paths

 mm/vmscan.c | 27 +++++++++++++++------------
 1 file changed, 15 insertions(+), 12 deletions(-)

-- 
1.8.3.1

