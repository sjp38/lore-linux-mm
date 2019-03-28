Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 471A6C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:37:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00F112184C
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:37:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hmBxWI3H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00F112184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95A2C6B028E; Thu, 28 Mar 2019 17:37:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E0EB6B0292; Thu, 28 Mar 2019 17:37:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D1E36B0293; Thu, 28 Mar 2019 17:37:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5BE136B028E
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 17:37:27 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id n13so253270qtn.6
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 14:37:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to;
        bh=CPHjTT59r+JSXq9n3OTZue3IyFe3usw1waSqlvsvRhg=;
        b=LdW/GdfeIY4SW+lkAqVgGyvk187aMwagPzsWIaQIhhwDvUnvCCCpSHDK2T+aqzh5J+
         LNgGpOmQ/X0BH1tqduOVLu/RL1tk88mnV1gvZ0qn7q5Zxq43EjYBTns0PeTKcNRKLXPb
         i5OBbyvX2gx0t5z/JnhavdOQR8DBYb40l6FAGoB2F+ScmWSxhmspMkpGEPzP2ivBHTmo
         7sz3xqZKUQjTGIJdxyZVBaXoxoNdlo75rOAAhjGhRRpsFep1kD0noO8SyL/kFgXvEVEn
         VWzIZGr2DfQzcgjN7JY7Hiz+/S2BpG5fVyScvYFzoFtnTCs6+XLKqgn3qn8l7W5geMr5
         19qg==
X-Gm-Message-State: APjAAAX/rnsNrQkDqU745KNTSQbB9MB8nmJuApgOvQKLaL++UVD75FT9
	o5helrt5KZaGCVfb+DRlbK4CYTBweXX1MRLX0cJPGoMs60KtMULgax0S5num6mE3FLeiG8k7I5Z
	uJ61CpJ7LGEj2/m/45l0C88Yae58k7egePmlnvJzMJKJiKfoAQQHIXwZjNwcRpBw9ug==
X-Received: by 2002:ac8:38b6:: with SMTP id f51mr15086987qtc.33.1553809047139;
        Thu, 28 Mar 2019 14:37:27 -0700 (PDT)
X-Received: by 2002:ac8:38b6:: with SMTP id f51mr15086961qtc.33.1553809046669;
        Thu, 28 Mar 2019 14:37:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553809046; cv=none;
        d=google.com; s=arc-20160816;
        b=j5OdI2Re0syiJbTs2fPUpdz2oUmD+tQMTZQIRD9hZVlFRiI5WzoU0NmVuoYKXGi4IY
         82ObJP9nI52XAfiXL0QiTG6XQaLySwZDdCLRhWjSnKblQmSYLG2nF5YrSqHEVmOqZVtE
         toXp48OhFProz/opURsc7rKc78U2uaJTwjcpYmIOnIgNE7z1lcVSiBol55TZxAmfMLzj
         aHeKc83nax2UjHz9zWuIw4t82y1PxmYZkzpqEc5zT4rwx2NWNEmftCSJsI0iJ5uhhEpb
         e2+9X+TeleySLNmX9N9v/Mo/KsV1UGWDBceGfctVOQMblg235KBwyXlnif7Obg4bW9LW
         ehFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=CPHjTT59r+JSXq9n3OTZue3IyFe3usw1waSqlvsvRhg=;
        b=opJjTwaDWD1b5pKiWGRjkuXpNm/XMJVvq82AoalgODfGofrhVHxu+gJlVT5H7mMbpJ
         cq1tgLgHIx4qf7IUepHb94vK550JznDdb1mseh1waAETL4IFQ9inARRzHShnnslySSU/
         ZbJe5RGM/4tnP+et17NEdAtifPZk+0qf3Tju/+YcH+m8mSqh/1MJyqtmUavVAGX2h8JJ
         NddFKfne8zOw8yyBBs8X4Vbmoj8PTKorU1uMGJNPDR6GJIadlLMnt3qMAA2cOONAatZr
         1yAs/X7N+cvFMTP9vLB45RFjBkOLNVUqpsAtGtsCZJHk7g77IId9lENdomNIwdz4BB0r
         0SOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hmBxWI3H;
       spf=pass (google.com: domain of vincent.mc.li@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=vincent.mc.li@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n12sor23922288qtc.52.2019.03.28.14.37.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Mar 2019 14:37:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of vincent.mc.li@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hmBxWI3H;
       spf=pass (google.com: domain of vincent.mc.li@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=vincent.mc.li@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=CPHjTT59r+JSXq9n3OTZue3IyFe3usw1waSqlvsvRhg=;
        b=hmBxWI3HKpgNaub2CKSdQgSTKMwXSPQh7bf825AAYhuWDTkQ6H7VWd0tR9hZdEtWMQ
         IxozKMjhr7wR4BM0Cat8i7IU0R4UZQmHqhR6DlpD8Nhjk77wagQBP4fip9gYN9U6pdjn
         OoNpaTgbXQzwpMaaizh189kprT4uprNC8goD2dxOAxUD/MuCEun8gbkYvMtFHMqmfO5U
         sKTblewUblt2Rq5ks4QBDMkmomDtG+XQhmX3fu+xE4aMxh4+7jedJ+Tj1JvgaoNQXlQN
         khyBoSye6DnfllS0Fihpk4M5qoWZ7gcOPULAjAz2pzuy+aNSRD1eUhl6j9Nlm7P2OHa0
         9NDw==
X-Google-Smtp-Source: APXvYqyl1nQW/lNiUCmJeeyeJvHDfKxN4Vh0fe/Te1Kf02gVIhZLE5Wn7MWAJXt0kq8w14D5FFLMZNoZnK/a4aV766w=
X-Received: by 2002:ac8:30f9:: with SMTP id w54mr38465895qta.336.1553809046346;
 Thu, 28 Mar 2019 14:37:26 -0700 (PDT)
MIME-Version: 1.0
From: Vincent Li <vincent.mc.li@gmail.com>
Date: Thu, 28 Mar 2019 14:37:15 -0700
Message-ID: <CAK3+h2xjr_h-3D9952SPUpN1HadyLz13gFmsAZWSTx9uz0sO3Q@mail.gmail.com>
Subject: sysrq key f to trigger OOM manually
To: Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

not sure if this is the right place, I tried to use echo f >
/proc/sysrq-trigger to manually trigger OOM, the OOM killer is
triggered to kill a process, does it make sense to trigger OOM killer
manually but not actually kill the process, this could be useful to
diagnosis problem without actually killing a process in production
box.

Regards,

Vincent

