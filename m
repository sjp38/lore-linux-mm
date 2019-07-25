Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24619C76186
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 02:43:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9CED21951
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 02:43:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9CED21951
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vx.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B6FC8E0026; Wed, 24 Jul 2019 22:43:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 267448E001C; Wed, 24 Jul 2019 22:43:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17D698E0026; Wed, 24 Jul 2019 22:43:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id ED5448E001C
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 22:43:42 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id s83so53257877iod.13
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 19:43:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=POX2Va2xbe6o7aDLzAnI+NIqNcdjNFRrZsMUzcQqD+k=;
        b=KhnqCC4e8oCdNEd9oNt4Z+517azcnnEx9NZ/650opeBIukAD4CYKZIqdmU4rep4VHR
         KxRks+6dcub4Mz7bE/AvuA4P9wA+cNdm0r12JOzZ3t/U2qKDSsbVd0T6KYJsUspIX0j9
         dYbmtv1WSEReYtFEbAmA2FsAw1jVPFO5/3m2HOQp2zYnYT4mpgAIkvwIvLO8Skvq1nAJ
         dG9Mhl7py++iM3dsGkDtOPUTYGwoZDpP5+2y6UcRjCS44X6jfgOQJ7StJRDPU/pPkRZl
         zpuLl0t9c4mo9u2F6JR3S2Rnmv26d8qba81HJkU+WVkN7BAawKAuH0yZFWtQb5B1ufO0
         fiBw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of t-fukasawa@vx.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=t-fukasawa@vx.jp.nec.com
X-Gm-Message-State: APjAAAX4HiswylF5LqznDBPaBjgEkIEikyHTmBn6WkMUU6eqB6JM1wM4
	ocpJzmpcHORb1Tqo3wkA4TcD3XBi759nc4vJ/RtZ2uaqZclpjVlZi6sHxHjM/ukoZaIUsZygSFX
	E/vWSU4HhS+wpth0tDiPEkl5Kzf3Hr4nHLxUw39HXWazgCBVen58IHyNGsf24Vh2TrA==
X-Received: by 2002:a6b:5106:: with SMTP id f6mr34054353iob.15.1564022622703;
        Wed, 24 Jul 2019 19:43:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJ8je7T0DgaR+5o9ltRJWJRlxAXM0hAUH1eMJ1rzgihiwD5O3ZUdXIAzOd2wnzAi5oGEN7
X-Received: by 2002:a6b:5106:: with SMTP id f6mr34054314iob.15.1564022621552;
        Wed, 24 Jul 2019 19:43:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564022621; cv=none;
        d=google.com; s=arc-20160816;
        b=Yrf3DaSgkdHjBgxZk2CyAkORF06njSc/YlIR9oVMQcm8a1RJo1HZPJfH0WW3MDapb3
         drgPn8st2Qx2imMh+WhH6VnUlyjj3xEhHqUlvsixZ9rcCibSMeG8V4ycxGoSzN1nfGvH
         /MjdkeThHTHlk0Kh5Vsb1sT6DQLbtR+5ahrSMjpDjryPXoeRmvT3ULV8G3HZmhPBFrSc
         SwAvz2SiyFeVrZL9CcNhvP50Xu9CYtltul2FtT5JNSQcN4waqbbMbUKACgTHuIwRYu9H
         LWEsK7L1T+JRg9yBxSrKMXxOEKCJp1fnR4t4UhC8WF22F+uvllyIUobyq09n1VqbR7Gs
         5V6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :cc:to:from;
        bh=POX2Va2xbe6o7aDLzAnI+NIqNcdjNFRrZsMUzcQqD+k=;
        b=E330koI6/gfB7I7Q9FW7HRnvn/ASuZ4w1S+HSfPBRP9PrkkWFLHzzq/JqjYKltAJH+
         xlWGbiBKfayTLEPxMMi5eNSqHVAVS6NQ9hAVBUdnHnzcKJBxcbXuDNt/Ii7F5/jwIVXs
         MO+EBCLMgtWbVxm9vXzqMcMpKnf+aZS18DXiwZmpbKbjLQ6Zo0zXlrdTNyIs93pAoCSS
         FelQxpVcXiIz9ZP1ZX1XnkaL2k9MFvdDTCRjubyQ2/3XQ8NIQIIrt7GGGv2paX+NDGMx
         nZWsOGvCKLqS5kdFSXHXHTNy11pyvkoONB3uEBKG5f+LmgZ1MSd5JyfvFS5zZrfgZNZH
         8Pog==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of t-fukasawa@vx.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=t-fukasawa@vx.jp.nec.com
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id c23si60054560iob.102.2019.07.24.19.43.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 19:43:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of t-fukasawa@vx.jp.nec.com designates 114.179.232.161 as permitted sender) client-ip=114.179.232.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of t-fukasawa@vx.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=t-fukasawa@vx.jp.nec.com
Received: from mailgate02.nec.co.jp ([114.179.233.122])
	by tyo161.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x6P2hUwb018127
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Thu, 25 Jul 2019 11:43:30 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x6P2hUXu005633;
	Thu, 25 Jul 2019 11:43:30 +0900
Received: from mail01b.kamome.nec.co.jp (mail01b.kamome.nec.co.jp [10.25.43.2])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x6P2gRmC020128;
	Thu, 25 Jul 2019 11:43:30 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.147] [10.38.151.147]) by mail03.kamome.nec.co.jp with ESMTP id BT-MMP-2430492; Thu, 25 Jul 2019 11:31:13 +0900
Received: from BPXM20GP.gisp.nec.co.jp ([10.38.151.212]) by
 BPXC19GP.gisp.nec.co.jp ([10.38.151.147]) with mapi id 14.03.0439.000; Thu,
 25 Jul 2019 11:31:12 +0900
From: Toshiki Fukasawa <t-fukasawa@vx.jp.nec.com>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "mhocko@kernel.org" <mhocko@kernel.org>,
        "dan.j.williams@intel.com" <dan.j.williams@intel.com>,
        "adobriyan@gmail.com" <adobriyan@gmail.com>, "hch@lst.de" <hch@lst.de>,
        "Naoya Horiguchi" <n-horiguchi@ah.jp.nec.com>,
        Junichi Nomura <j-nomura@ce.jp.nec.com>,
        Toshiki Fukasawa <t-fukasawa@vx.jp.nec.com>
Subject: [PATCH 0/2] fix kernel panic due to use uninitialized struct pages
Thread-Topic: [PATCH 0/2] fix kernel panic due to use uninitialized struct
 pages
Thread-Index: AQHVQpEGSdyTWH0GVESV/sMpt20Kgg==
Date: Thu, 25 Jul 2019 02:31:11 +0000
Message-ID: <20190725023100.31141-1-t-fukasawa@vx.jp.nec.com>
Accept-Language: ja-JP, en-US
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.135]
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A kernel panic was observed during reading /proc/kpageflags for
first few pfns allocated by pmem namespace:

BUG: unable to handle page fault for address: fffffffffffffffe
[  114.495280] #PF: supervisor read access in kernel mode
[  114.495738] #PF: error_code(0x0000) - not-present page
[  114.496203] PGD 17120e067 P4D 17120e067 PUD 171210067 PMD 0
[  114.496713] Oops: 0000 [#1] SMP PTI
[  114.497037] CPU: 9 PID: 1202 Comm: page-types Not tainted 5.3.0-rc1 #1
[  114.497621] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS =
rel-1.11.0-0-g63451fca13-prebuilt.qemu-project.org 04/01/2014
[  114.498706] RIP: 0010:stable_page_flags+0x27/0x3f0
[  114.499142] Code: 82 66 90 66 66 66 66 90 48 85 ff 0f 84 d1 03 00 00 41 =
54 55 48 89 fd 53 48 8b 57 08 48 8b 1f 48 8d 42 ff 83 e2 01 48 0f 44 c7 <48=
> 8b 00 f6 c4 02 0f 84 57 03 00 00 45 31 e4 48 8b 55 08 48 89 ef
[  114.500788] RSP: 0018:ffffa5e601a0fe60 EFLAGS: 00010202
[  114.501373] RAX: fffffffffffffffe RBX: ffffffffffffffff RCX: 00000000000=
00000
[  114.502009] RDX: 0000000000000001 RSI: 00007ffca13a7310 RDI: ffffd074890=
00000
[  114.502637] RBP: ffffd07489000000 R08: 0000000000000001 R09: 00000000000=
00000
[  114.503270] R10: 0000000000000000 R11: 0000000000000000 R12: 00000000002=
40000
[  114.503896] R13: 0000000000080000 R14: 00007ffca13a7310 R15: ffffa5e601a=
0ff08
[  114.504530] FS:  00007f0266c7f540(0000) GS:ffff962dbbac0000(0000) knlGS:=
0000000000000000
[  114.505245] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  114.505754] CR2: fffffffffffffffe CR3: 000000023a204000 CR4: 00000000000=
006e0
[  114.506401] Call Trace:
[  114.506660]  kpageflags_read+0xb1/0x130
[  114.507051]  proc_reg_read+0x39/0x60
[  114.507387]  vfs_read+0x8a/0x140
[  114.507686]  ksys_pread64+0x61/0xa0
[  114.508021]  do_syscall_64+0x5f/0x1a0
[  114.508372]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[  114.508844] RIP: 0033:0x7f0266ba426b

Earlier approach to fix this was discussed here:
https://marc.info/?l=3Dlinux-mm&m=3D152964770000672&w=3D2

This patchset is another approach to fix it and also provide
a fix for potential future bugs discovered in the process.

Toshiki Fukasawa (2):
  /proc/kpageflags: prevent an integer overflow in stable_page_flags()
  /proc/kpageflags: do not use uninitialized struct pages

 fs/proc/page.c           | 40 +++++++++++++++++++++-------------------
 include/linux/memremap.h |  6 ++++++
 kernel/memremap.c        | 20 ++++++++++++++++++++
 3 files changed, 47 insertions(+), 19 deletions(-)

--=20
1.8.3.1

