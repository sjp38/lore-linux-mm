Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C1A8C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 09:28:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9B65214D8
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 09:28:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9B65214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 751A86B0003; Mon, 18 Mar 2019 05:28:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 700976B0006; Mon, 18 Mar 2019 05:28:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 616756B0007; Mon, 18 Mar 2019 05:28:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 106056B0003
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 05:28:06 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id p18so298916ljc.17
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 02:28:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state
         :content-transfer-encoding:subject:from:to:date:message-id
         :user-agent:mime-version;
        bh=DuZE/6E4RQuviBZlBT+hgki0y+7dVOZssCNASRxLWO0=;
        b=Yr8Yewk1xtl6VgNd5xbMSeu/97m6aGkb2xtU+IFM1DD5U2XUy1wLuuGi0GCwxL1qPC
         opk6XYzpdrBqtCkx4t0vt2aIhqVHNoJjEOD0iXhOeQo0nz3JFCB4ZOAyE2feCguM+Tzr
         YmKs7Hycj9TVgpq5mzIWVWthMZsHKofBLMFYI1A4fRhrtzuKCYbasfAV4H7pYy1ckBXo
         oDmVkYxE2/GPstsaeOLWAEwMvwbheLy0aAllidRGu+vRZQ2pLNbU5cztcs381hFJQBC0
         iJ0VycV+YvL2GpmZDz7taMuHVEtZPGPoKp1wjfBvyLbOB7SakjCJaiC9B1WfeThXio9q
         9CmQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAV5bezbgCTqvg5IRgX/4emW6oRYK0HBr2oirLXdTOFhUIZ3HFbt
	wdGyyjlP8uAUwErVW5qoegltgGnhO5AGG8r7VckzlL8zrVnkLPVnpZ+EoRMRrGlsrPav40fBLbL
	/f5Y20oNcnXiWziq3WSkX8cRd02Ar75gfMZxbj1jxm1M2jRcyd8r1UBxMqiuYoci6cA==
X-Received: by 2002:a19:81c9:: with SMTP id c192mr9714475lfd.108.1552901285188;
        Mon, 18 Mar 2019 02:28:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvXZmy+NmIt3TViVcRw1Mzs801sfHMDn77J4autaRtUzWWM53mzErgnFTbJKcI/iW9cOab
X-Received: by 2002:a19:81c9:: with SMTP id c192mr9714432lfd.108.1552901284230;
        Mon, 18 Mar 2019 02:28:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552901284; cv=none;
        d=google.com; s=arc-20160816;
        b=i8GWMtIZ5N8XeRmUgNmCW8ufnQ+UVps++5X3rypFsfZHwfQfZUxcAnFbdEeGOGXTa/
         g7O0uunV8vVL9VrniSi3kOMYF6oDeiY+7OGL/7GcdDJ55xfPeqoaGKhwxwyahST7uapd
         HHRhi/sDwNcHJVpcUoMNeOyfliz8K52TqzWDmvlp6YlTH096vH+ImCnGb6vKFlNy/pJE
         Afs1Jv8uS6LWo6yoq6bNQk5/JSHYBlZpk8huP1mXZ7v+tAns3QvtFdKCplzdWSAP3nGm
         fPFbKKq0yXbpeOLNjjS21OBii3Hj9HoAciyitAXih9e3kO76RgbKrLqenGweD+OzC5Aw
         dQJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:date:to:from:subject
         :content-transfer-encoding;
        bh=DuZE/6E4RQuviBZlBT+hgki0y+7dVOZssCNASRxLWO0=;
        b=rSKqvtqhGYJFDd+bBFIzHTCaouzFCDikSayPtixtcH5NaQRFgPpfhK2fsIG1aSSe1+
         +dVcW9JQChMTn1rAiTYOmctt6OIXuF9r6yBgvGs0+GaZ8AScsSLrbgbVyOxRZIpmFs/G
         4i30pTpVOuu2WKk1ZSl/tbEA7YAcIozukwH3NsHKvj/FWhUOPgJM4TJfmIY/w261tJyl
         /S26UA25V2jNX9s49tHKeYw0K69Pw1llakqC6IarBLkgxTIPo2e/1qwnJPXOae7TnESv
         mnb05QZ9OWoCLCAzPsP4kC8ofKo2X/hX/i+i5EIlbxQLdZA9Bnn7Y4OU9qI6VrAAvoDU
         iX0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id s14si6912842lji.137.2019.03.18.02.28.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Mar 2019 02:28:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1h5oYk-00054y-Ad; Mon, 18 Mar 2019 12:27:54 +0300
Content-Transfer-Encoding: 7bit
Subject: [PATCH REBASED 0/4] mm: Generalize putback functions
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, daniel.m.jordan@oracle.com, mhocko@suse.com,
 ktkhai@virtuozzo.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Mon, 18 Mar 2019 12:27:53 +0300
Message-ID: <155290113594.31489.16711525148390601318.stgit@localhost.localdomain>
User-Agent: StGit/0.18
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

(This is resending of the patchset, rebased on next-20190318).

Functions putback_inactive_pages() and move_active_pages_to_lru()
are almost similar, so this patchset merges them in only function.

v3:   Replace list_del_init() with list_del()
v2.5: Update comment
v2:   Fix tracing. Return VM_BUG_ON() check on the old place. Improve spelling.
---

Kirill Tkhai (4):
      mm: Move recent_rotated pages calculation to shrink_inactive_list()
      mm: Move nr_deactivate accounting to shrink_active_list()
      mm: Remove pages_to_free argument of move_active_pages_to_lru()
      mm: Generalize putback scan functions


 .../trace/postprocess/trace-vmscan-postprocess.pl  |    7 +
 include/linux/vmstat.h                             |    2 
 include/trace/events/vmscan.h                      |   13 +-
 mm/vmscan.c                                        |  148 +++++++-------------
 4 files changed, 68 insertions(+), 102 deletions(-)

--
Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>

