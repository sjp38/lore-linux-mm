Return-Path: <SRS0=K2XS=UI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 984F8C28EBD
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 10:08:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9B5F20693
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 10:08:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="SA+8YOG3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9B5F20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BA326B0005; Sun,  9 Jun 2019 06:08:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46AAD6B0006; Sun,  9 Jun 2019 06:08:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 35A996B0007; Sun,  9 Jun 2019 06:08:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id C75CD6B0005
	for <linux-mm@kvack.org>; Sun,  9 Jun 2019 06:08:52 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id s14so735546ljd.13
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 03:08:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:user-agent:mime-version:content-transfer-encoding;
        bh=A1Nf6U0SvfT2BlL//D1jO+fs0ZHFTGiIegZYeSRr5dQ=;
        b=dtHvLqeag2eNDeeyp704/DwS6RsQYpObwMMtsgdvk7TN/yTmL7TGJASFj0qNkLNqbk
         ADYLtxiy0Yvm0pfMh1Zw0xxev3dksm3LzR4gsC/tvsr9FEeSXcYxSA/hqdFjiGG6U1oE
         6Sh068UZehaNO6fYRcy+cNKHDbuA44Fi/l3GtiLODhbH8Y42rhnEQ8oN+YO9Oe3et8TB
         pjZ2h1OAMY6/O8nIdBHD73xtRekkzZXlvV0tCw/t1fvbIj3eY9TElu5kESGJQGB9jTZh
         l/KisVbenaq/ohgn9qnA2mWcGFinJDF2AbU5EXqb7201lCIaqAFXztDCj6nc+rUgtpNp
         vo1Q==
X-Gm-Message-State: APjAAAWsZquZh1p6eFj5j5jPFDHb+95Hf5dBFEw9lHHdDGmeEUm/2EMb
	dPAFB6OLQKXCvTCOE8yNsXobDQsa8SJ0GPTgvY9kjxAvL5Y54Y172jD5ocYGOhrH9HJrIwtZ+Gc
	MIHWohhuMTZX9SFFsiodARG5HJT7FM1ebuy9bL5DtUOqrZ6R82k4W1nS3mWzCAotDSg==
X-Received: by 2002:ac2:43b7:: with SMTP id t23mr30321420lfl.110.1560074931995;
        Sun, 09 Jun 2019 03:08:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw55Kz3M4LJzJ5S4mzACrbwmmukGfJpz6NcAMf4nAf5UeJ56fTSQut2c8eHC2ClbXkVt3xL
X-Received: by 2002:ac2:43b7:: with SMTP id t23mr30321400lfl.110.1560074931126;
        Sun, 09 Jun 2019 03:08:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560074931; cv=none;
        d=google.com; s=arc-20160816;
        b=xZR8dWPT87X/xoLG/SaYU+UmE1dx8u5yuz9gh3Mk35r6iBTsXjyeV8N96AvFLBbQ92
         WcAJ2ONMVGYSeR2P0659AunypZjAdani0n+MODSTR+XJSkUCizbplJ3G80aLb6mAAaeq
         ujW7+D37kZW6qDQaw4vO7LiTzhww4JuUiOSDK5DV8kOZJlCuGIJIcZyaqzhQtTA4ntCF
         TyGY+2V8QgI4ZeXIdEBABha0u0kLpaH9WOQoRrFI0tWPuBqedt11mWqnouF8OzmfzdVv
         k9fTGMHEi73teIBrnbvmcKL2WEd3geroUKG6SlU7ZC2kzJg8p6kP8nvwzTY3IlLicnBd
         MpZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject:dkim-signature;
        bh=A1Nf6U0SvfT2BlL//D1jO+fs0ZHFTGiIegZYeSRr5dQ=;
        b=XM62j6kWkDlMI+yT+2MyX9X0WgShRtZUopmRUja/XQe9Oqw8S0lbwlBtbmpbg3Ko2T
         U5LZhCp1O4SCUEh6VmA4vriXJDN5TpEUfS9f4gNrQ1dotMqixRpTi30IwdHHYBdFdhUW
         J30ssjXIL2LxVMS625Vyfismie48R/fL/k899Rk/ZrGel/PxoxWtgSrx2EKtT03hT1wW
         MV4qRhV2dNqoCFhYLi9j6mI+YymGdnOjqKX5BuqlApIG+pg/2cgspk/dM6XcBh/SSgiV
         8sSaBb0Z51hJ1gZcJCGHHNRVaFJS5PcpMBgLlpa5lr1GtN0U0lD+WibGx8nscR7hZAtv
         PIxA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=SA+8YOG3;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 77.88.29.217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1p.mail.yandex.net (forwardcorp1p.mail.yandex.net. [77.88.29.217])
        by mx.google.com with ESMTPS id a7si6052299ljd.210.2019.06.09.03.08.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jun 2019 03:08:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 77.88.29.217 as permitted sender) client-ip=77.88.29.217;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=SA+8YOG3;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 77.88.29.217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1j.mail.yandex.net (mxbackcorp1j.mail.yandex.net [IPv6:2a02:6b8:0:1619::162])
	by forwardcorp1p.mail.yandex.net (Yandex) with ESMTP id 72C702E1466;
	Sun,  9 Jun 2019 13:08:50 +0300 (MSK)
Received: from smtpcorp1p.mail.yandex.net (smtpcorp1p.mail.yandex.net [2a02:6b8:0:1472:2741:0:8b6:10])
	by mxbackcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id 2urtvvwpVi-8nOa9Lfg;
	Sun, 09 Jun 2019 13:08:50 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1560074930; bh=A1Nf6U0SvfT2BlL//D1jO+fs0ZHFTGiIegZYeSRr5dQ=;
	h=Message-ID:Date:To:From:Subject:Cc;
	b=SA+8YOG3X58lzzkWQxUgsq5XNkRaEMhVLAik6vgAWA+LyhIPHKXPgzRv8MpB3TJ+w
	 F7x2Xwlkvj1bevytfO9ytA3lDrG88xYiiYv6hgsvKmZnnN5adJyE7z06mM4GmclYnh
	 bNGsFLf3hPwpIcii0K+apf2qgVIRyuqYMl5gDgpM=
Authentication-Results: mxbackcorp1j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:3d25:9e27:4f75:a150])
	by smtpcorp1p.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id 4GNAteVf4o-8ngWxpn4;
	Sun, 09 Jun 2019 13:08:49 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH v2 0/6] mm: use down_read_killable for locking mmap_sem in
 proc
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-kernel@vger.kernel.org
Cc: Oleg Nesterov <oleg@redhat.com>, Matthew Wilcox <willy@infradead.org>,
 Michal Hocko <mhocko@kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>,
 Kirill Tkhai <ktkhai@virtuozzo.com>,
 Michal =?utf-8?q?Koutn=C3=BD?= <mkoutny@suse.com>,
 Al Viro <viro@zeniv.linux.org.uk>, Roman Gushchin <guro@fb.com>
Date: Sun, 09 Jun 2019 13:08:49 +0300
Message-ID: <156007465229.3335.10259979070641486905.stgit@buzz>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

v1:
https://lore.kernel.org/lkml/155790967258.1319.11531787078240675602.stgit@buzz/

v1 "mm: use down_read_killable for locking mmap_sem in access_remote_vm"
https://lore.kernel.org/lkml/155790847881.2798.7160461383704600177.stgit@buzz/

changes since v1:
* update comments and collect acks/reviews.

---

Konstantin Khlebnikov (6):
      proc: use down_read_killable mmap_sem for /proc/pid/maps
      proc: use down_read_killable mmap_sem for /proc/pid/smaps_rollup
      proc: use down_read_killable mmap_sem for /proc/pid/pagemap
      proc: use down_read_killable mmap_sem for /proc/pid/clear_refs
      proc: use down_read_killable mmap_sem for /proc/pid/map_files
      mm: use down_read_killable for locking mmap_sem in access_remote_vm


 fs/proc/base.c       |   27 +++++++++++++++++++++------
 fs/proc/task_mmu.c   |   23 ++++++++++++++++++-----
 fs/proc/task_nommu.c |    6 +++++-
 mm/memory.c          |    4 +++-
 mm/nommu.c           |    3 ++-
 5 files changed, 49 insertions(+), 14 deletions(-)

--
Signature

