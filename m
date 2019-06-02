Return-Path: <SRS0=2YS/=UB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 719A5C282DC
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 09:23:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D8F4278A6
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 09:23:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ugjB4l0d"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D8F4278A6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3458F6B0003; Sun,  2 Jun 2019 05:23:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F5F66B0005; Sun,  2 Jun 2019 05:23:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1BE046B0006; Sun,  2 Jun 2019 05:23:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id D76E76B0003
	for <linux-mm@kvack.org>; Sun,  2 Jun 2019 05:23:19 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e20so7700907pgm.16
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 02:23:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=h7/sc5h9WgiFsGWJQ16HeJ0k14UeSaQXaZQVtIYPph4=;
        b=ti/xcjyqc92E0fwrNobHI8L7K3xZ6MOFj87xSHyXlZ7JGC3OEjF1CSq42v9mBnyPH1
         2wefeKiCJP3I/a+sqx6ydurX+P8C9t1r6n6lJsmb/t7BMbfPH+KcFOSjU5i99P19p1fS
         udCZOQifXwU6GWbsdqj9uR71YMkW8IrHXnbtZM7S5Y99Qe8hS6tnuguBU+6xwHIqOo6/
         qDYVWG9nrleiPyZaJ7V+aKxbMfSnf2qI3W8Lrk20yIYlACgs5T8YzSZ2LDrWY9njG9MG
         4ktFHjJEWS9LttKCGiiyLDG7uzqAiFHuU3O2CSpYXZMQfzzwjxNePg4jibp6/FfbvZo2
         TZ4g==
X-Gm-Message-State: APjAAAX5gLwbPXwldhKjnE7tZdv/pgKTHKhIHxzjjplBpQCDtsWQjfyM
	hQhwaKcmsAkij0wHbYqs75mK7CNjpIz/VZQHW6sT/Msf7P+4b4zA7xOsFpgnEHvJmgbtik4ZvBE
	9Lw6rIJ1y2p/zjxHhO5K8Y+lbwkNFsgZs3pfW/OsRo0av9Sv1pmVFWVlVrSEv/9vq5w==
X-Received: by 2002:a63:f513:: with SMTP id w19mr16809025pgh.367.1559467399210;
        Sun, 02 Jun 2019 02:23:19 -0700 (PDT)
X-Received: by 2002:a63:f513:: with SMTP id w19mr16808966pgh.367.1559467397746;
        Sun, 02 Jun 2019 02:23:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559467397; cv=none;
        d=google.com; s=arc-20160816;
        b=RZgfnDbvFvdHHLyRsqoJaRYmw2rNxbXbVyzFqOjaLO3ElS0cCmW/Z1+GLQ8YC37S9V
         qZONoSOdyHTkWryzBZyVPCqMHCHLp5ileFCxd98V03WOzddjFKMeT+I0migX18HBfRqz
         3CHxtchYkoIW+ErryziWsFbf1vQZ/YTTG+bL6dXS/xr9L8TK2YwyoSKUyzX7EjQwq5te
         zXjVgNRvAA9bT6je+2QGnEzVVwgkOpdqXPK8PNHcCsR6JRmOLO0tZsOuONpGezcmXhKw
         wNHdRFS7hPV6o2Pqorv920dMw3s/kAs1h4VFLWOMXuzr/HdbMfr5cWfiWlwwek5Pt/nb
         KkmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=h7/sc5h9WgiFsGWJQ16HeJ0k14UeSaQXaZQVtIYPph4=;
        b=NchFQKdCsF5Z6apFQIzwTqnWpWXvIM9zSN4710G62HPazk04D560f6IG1v+fEW+uoj
         6pQ7cwnkZ+yp0MrZ1BOESh6RYkOT7Am/QOtXlkBViRgWQm5BAE/K/H+E+DGwv8WLjUer
         tlB2L2p6QQneViJG+2LRxmeROiEj8DUjNQGAl+epgUxb/kvYeB4x3LKgWw3wMUwqb+Ww
         GMLjPmo9MMo+uH7ljWO1jZyaBdvY5Lo/rV2A1T1lonJQHBY6UsOtieaNIaoorl0hPJNF
         6JNWp5ixrkCJ+Ufm7GEBOEcsNoI2tIdnQBOK+4LUfei5TmTQ2cQoeaBLVK/M+JyQTCEq
         UxLA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ugjB4l0d;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v61sor12989036pjb.2.2019.06.02.02.23.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 02 Jun 2019 02:23:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ugjB4l0d;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=h7/sc5h9WgiFsGWJQ16HeJ0k14UeSaQXaZQVtIYPph4=;
        b=ugjB4l0dMXNX76+fPDQN+hoLJ+73aAINIjJJh7W+w8xEDx3UUE0oHIyLDUF+RglH/Q
         K3xUAYnGqzpuvUZy1vW8GQ6zil5ADIVMGGJ1omb0gjpKsGL07O0LfpvvGzmpm70vLGNa
         dyF+xEPN7I+5ox1P7iHNJfyPFQj8ry+m8NopCUL3YgeFLdFIGeQnO9Tnep3NTUUmPKxd
         Sg/UEZbih8A8t/SqP5LuQ52OKGPS2ZeZUo7V7jMZcD02gH+CWfQVyidGd6ubGMJRmQPK
         984ql6ZlOJUlQyM4T1o3c7M8aUuMynv5Nf3sE6kgNOS3X9HVhyCgJSi98JTAm/TBT4DG
         ojfg==
X-Google-Smtp-Source: APXvYqw4cLCgvqHbpUiIji+9ipe85MmrpAy8/GO18Po4/8O63dhOPfHHEsJCferD3Xk/JfIJRohz7Q==
X-Received: by 2002:a17:90a:cf0b:: with SMTP id h11mr15320576pju.90.1559467397337;
        Sun, 02 Jun 2019 02:23:17 -0700 (PDT)
Received: from localhost.localhost ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id t124sm11633191pfb.80.2019.06.02.02.23.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jun 2019 02:23:16 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: mhocko@suse.com,
	akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH v3 0/3] mm: improvement in shrink slab
Date: Sun,  2 Jun 2019 17:22:57 +0800
Message-Id: <1559467380-8549-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In the past few days, I found an issue in shrink slab.
We I was trying to fix it, I find there are something in shrink slab need
to be improved.

- #1 is to expose the min_slab_pages to help us analyze shrink slab.

- #2 is an code improvement.

- #3 is a fix to a issue. This issue is very easy to produce.
In the zone reclaim mode.
First you continuously cat a random non-exist file to produce
more and more dentry, then you read big file to produce page cache.
Finally you will find that the denty will never be shrunk.


Yafang Shao (3):
  mm/vmstat: expose min_slab_pages in /proc/zoneinfo
  mm/vmscan: change return type of shrink_node() to void
  mm/vmscan: shrink slab in node reclaim

 mm/vmscan.c | 33 +++++++++++++++++++++++++++++----
 mm/vmstat.c |  8 ++++++++
 2 files changed, 37 insertions(+), 4 deletions(-)

-- 
1.8.3.1

