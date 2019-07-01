Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 141D5C5B578
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 21:57:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AEFFA206E0
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 21:57:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="Ab58Caql"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AEFFA206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=wdc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5AAE36B0003; Mon,  1 Jul 2019 17:57:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 55B1F8E0003; Mon,  1 Jul 2019 17:57:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 452D88E0002; Mon,  1 Jul 2019 17:57:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f205.google.com (mail-pl1-f205.google.com [209.85.214.205])
	by kanga.kvack.org (Postfix) with ESMTP id 0A4266B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 17:57:39 -0400 (EDT)
Received: by mail-pl1-f205.google.com with SMTP id i3so7904209plb.8
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 14:57:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:ironport-sdr:ironport-sdr:from:to
         :cc:subject:date:message-id;
        bh=kbh7J9Mux7s/C4nO6LoFuRhu03rSNh7Lz5ZLQPbij7c=;
        b=EjEJyUU4HXmDSdmwSKWoIUoLtsMM6tElz4huCv68sObIH2k/V9TLbZYMc0nhs+f/zd
         1Ysl3rGnzk61ZBdXEqVEhh2VC2nzGVjKMnqjPenAPIeA+jCjL6vDxSero750e8RxTaEI
         WZD+z2oirMDIGV5G0EqrS+HVIXUX6ER9O04NSEuu9EX5/6s88Wog0Josp2P7KUFAoRzi
         3xqACNiZujjq1/Ier6tNXXpINHFMXbKFYuw51okYW9+B25goeSQSv4aG9hup2tScdQ/5
         VELi/HRAKnazkMhgbiV0hqLKCjk8HbqUVRhN9m5sFLsdmMvRRS0GGksf117G/Y941MW7
         gf7Q==
X-Gm-Message-State: APjAAAUSt/+Hkmp8VPJjS4e0t5pA+Wh5zx4JsR+bQyzUkcUZHdZK5NIA
	J1KghKIbWaqAJ1IhF+A4U5wGDu2ZJ4JlKGH1ac5wt1VORUQ5muvvj7LuZKViJjQUGiOuwgau+kI
	ZxR8z1GjAEHDIEFjn4kvesi8NVaU7tFsGMCCsZmaaadFqvBl/VcWC/2GYGJEIpqZKLg==
X-Received: by 2002:a63:5c15:: with SMTP id q21mr27772603pgb.248.1562018258621;
        Mon, 01 Jul 2019 14:57:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyX2KHIKawzidG6mzKX5n3on4WxKHlNBuCe7BKEPUVVFtZ+SkNbk1Q/H5rzNTlMze5YY6RE
X-Received: by 2002:a63:5c15:: with SMTP id q21mr27772546pgb.248.1562018257693;
        Mon, 01 Jul 2019 14:57:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562018257; cv=none;
        d=google.com; s=arc-20160816;
        b=aZ3bYikDkfWjVoEDkG3OXbj0xF2PuzJn1Sam6PM79gMhYTl9k2myWdRGdNp0+3ZzX8
         NG7cQudZ2aXEWMRaefjyLAFJQtihe6aPsUssOCUva7a0ak3OUtA7zST2ZkAHM3PoIvDn
         IzlrUmRnRAQdXHvcr7UmYaxeJ8W9xJjWwzXhwtsdcp/FE2MwwsF0X5XaTaO68iMfIyM9
         iPyjqddeXCS/qcwmDLSI2wZAs0dFrzd2t+fIzppubzeZt8pAp1SiVvbhgKFNLWQwSjvf
         k18/b9eONbLMn0p9G96mmf4GDgEieOCgkE29UZZy40E9NMXUFa3HiZ1kDPBZnYMmwJnX
         yITQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:ironport-sdr:ironport-sdr
         :dkim-signature;
        bh=kbh7J9Mux7s/C4nO6LoFuRhu03rSNh7Lz5ZLQPbij7c=;
        b=tQsc4nk8137XoG59EPqW6YEvfjwRDs3RWeWnukh4Beo+6Wx1SyQg9MMDfgqjB6P4KS
         JB5PDxdtp93O2aO1lrm/fWYCmnfvcmSIjBk7HMXRzVpcfxRibGagui4waBFjr0QdBKkJ
         a/pp30pY2bVhwF0otu/vGXcsBTqJ6Mv969kWOb5VpinSlK7TU5OTUXF+E7VNZZzzqDCb
         5KyLFR0yh/5spEtQ2oPKwZKK+FBj1iROeHWedg1YnQsvdhnP/JyXO84VxXhFNLAkgDzZ
         J0llKPu2RqJMYbTkwfq4CyN0uqi2OUE0cfExGlIjAl1EviNie4h6pS2dolcV+cdzcnKe
         YUlg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=Ab58Caql;
       spf=pass (google.com: domain of prvs=0789f8ff9=chaitanya.kulkarni@wdc.com designates 216.71.154.45 as permitted sender) smtp.mailfrom="prvs=0789f8ff9=chaitanya.kulkarni@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
Received: from esa6.hgst.iphmx.com (esa6.hgst.iphmx.com. [216.71.154.45])
        by mx.google.com with ESMTPS id be3si10749441plb.383.2019.07.01.14.57.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 14:57:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0789f8ff9=chaitanya.kulkarni@wdc.com designates 216.71.154.45 as permitted sender) client-ip=216.71.154.45;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=Ab58Caql;
       spf=pass (google.com: domain of prvs=0789f8ff9=chaitanya.kulkarni@wdc.com designates 216.71.154.45 as permitted sender) smtp.mailfrom="prvs=0789f8ff9=chaitanya.kulkarni@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1562018258; x=1593554258;
  h=from:to:cc:subject:date:message-id;
  bh=qHPV8j7yPVDlKUtbgMMWa08uXGi3zRdtGJmZ1qQMtyE=;
  b=Ab58Caql0k8d2897ypx7ogGxVWmB5f5XeUOh3sV15GDEHU7RVf5aFtt/
   ffyErcjLT2OVq6VzhMCjTpu20RJ/s3Bj6a8dS2RaxdM9TECp+wYQqdiDP
   al2tF+pzr45/r2ZpFK7P9RnzFbVH5Pzm7E+5ouoPygdwh6gdwzJkBdNp3
   NLupmFxQg0jaaJWrsyYQ8nOH9dl5r2+/zZgQK+QBhfxjzdMJXuH7/2Mcj
   1mQbZYS8D7UIdHdfnFmPzIa1iOMwPcebmcgRtw4PYZrzk/bcktygaCopo
   VxReK/7t06mAK+wmruRaWa/6Lki8Eam/eqiODIZrmXUI9kEdaMM0WGyWS
   g==;
X-IronPort-AV: E=Sophos;i="5.63,440,1557158400"; 
   d="scan'208";a="113614910"
Received: from h199-255-45-15.hgst.com (HELO uls-op-cesaep02.wdc.com) ([199.255.45.15])
  by ob1.hgst.iphmx.com with ESMTP; 02 Jul 2019 05:57:37 +0800
IronPort-SDR: 8ux5BpnWvNAAaWdEi/lDFydNenu/H2+pP4ZCVgAOEEgxar7q2XDrEMDHcDmg/JNmRpiL6tcaR4
 TO1iqU5UWwmjCNt2wzoLetZ1B80Rzx1SbNasbCHZ8yBFxUnmciZ6cAi1Geo4JX1o8jyTC/6op7
 j7wlsi0MJlkpQQgzk2KtyQN/oQofQvFgnqzv6jJ6Uj24/Q5YE9v4LDMKkWh7oeV9iuPG+MN4Sn
 vCcvBrC8JSDRKDo3X9FNaTsKFfTtB7u4Q3SHqUSy4oLD5qxJWr2EvcTUCQq+2VQRrPfilBdK6r
 /FLPaLLlVQjUsPJer1RiqkLV
Received: from uls-op-cesaip02.wdc.com ([10.248.3.37])
  by uls-op-cesaep02.wdc.com with ESMTP; 01 Jul 2019 14:56:40 -0700
IronPort-SDR: /Z4+8D0k91BrFb6d8BFBl6MJ45BZlRAdYYzdL3oXvd24qnVK1JxjuJLL66M5jJymyeBu275DQU
 uPCeCuiIzMoNHoTpePEuYDjvZiu26feu2qxPrpVtt/pbR3BBQa8nOd1Zg4frqAwpKhOgToJIqZ
 xkFTc1/Quq0dUNI3UiXM/2RiZaqdJE09xnZOHFXtZXylPazWe4N+rLmy3eG8hpz59skFtVuYd2
 CeT6fvjfAhevkU876StxG6OU2ISVQ7qQnbSv3Sn3QJf6D/grcxBkDAHXBjAdkr0UH6yDcRqYMt
 ycs=
Received: from cvenusqemu.hgst.com ([10.202.66.73])
  by uls-op-cesaip02.wdc.com with ESMTP; 01 Jul 2019 14:57:37 -0700
From: Chaitanya Kulkarni <chaitanya.kulkarni@wdc.com>
To: linux-mm@kvack.org,
	linux-block@vger.kernel.org
Cc: bvanassche@acm.org,
	axboe@kernel.dk,
	Chaitanya Kulkarni <chaitanya.kulkarni@wdc.com>
Subject: [PATCH 0/5] block: udpate debug messages with blk_op_str()
Date: Mon,  1 Jul 2019 14:57:21 -0700
Message-Id: <20190701215726.27601-1-chaitanya.kulkarni@wdc.com>
X-Mailer: git-send-email 2.17.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

This patch-series uses newly introduced blk_op_str() to improve
existing REQ_OP_XXX messages. The first two patches we change the
bio_check_ro() and submit_bio() and make debugging more clear and
get rid of the 1:M mapping of the REQ_OP_XXX to debug string
(such as printing "READ" and "WRITE") with the help of blk_op_str().

Later 3 patches are focused on changing the block_dump in submit_bio(),
so we can log all the operations and update the respective
documentation.

This is needed as we are adding more REQ_OP_XXX with last bit set 
as a part of newly introduced Zone Block Device Zone Open, Zone Close
and Zone Finish operations which are mapped to new REQ_OP_ZONE_OPEN,
REQ_OP_ZONE_CLOSE and REQ_OP_ZONE_FINISH respectively [1].

With this patch-series, we can see the following output with respective
commands which are clear including the special REQ_OP_XXX
(Write-zeroes and Discard) :-

# blkzone reset /dev/nullb0			# Reset all the zones 
# blkdiscard -o 0 -l 4096 /dev/nullb0		# discard 8 sectors 
# blkdiscard -o 0 -l 40960 /dev/nullb0		# disacrd 80 sectors  
# blkdiscard -z -o 0 -l 40960 /dev/nullb0	# write-zero 80 sectors
# dmesg  -c 

<snip>
[ 1161.922707] blkzone(10803): ZONE_RESET block 0 on nullb0 (0 sectors)
[ 1161.922735] blkzone(10803): ZONE_RESET block 524288 on nullb0 (0 sectors)
[ 1161.922750] blkzone(10803): ZONE_RESET block 1048576 on nullb0 (0 sectors)
[ 1161.922762] blkzone(10803): ZONE_RESET block 1572864 on nullb0 (0 sectors)
[ 1186.949689] blkdiscard(10834): DISCARD block 0 on nullb0 (8 sectors)
[ 1195.145731] blkdiscard(10844): DISCARD block 0 on nullb0 (80 sectors)
[ 1212.490633] blkdiscard(10854): WRITE_ZEROES block 0 on nullb0 (80 sectors)
<snip>

Regards,
Chaitanya

To: linux-mm@kvack.org
To; linux-block@ linux-block@vger.kernel.org
Cc: Bart Van Assche <bvanassche@acm.org>
Cc: Jenx Axboe <axboe@kernel.dk>

[1] https://www.spinics.net/lists/linux-block/msg41884.html.

Chaitanya Kulkarni (5):
  block: update error message for bio_check_ro()
  block: update error message in submit_bio()
  block: allow block_dump to print all REQ_OP_XXX
  mm: update block_dump comment
  Documentation/laptop: add block_dump documentation

 Documentation/laptops/laptop-mode.txt | 16 ++++++++--------
 block/blk-core.c                      | 27 +++++++++++++--------------
 mm/page-writeback.c                   |  2 +-
 3 files changed, 22 insertions(+), 23 deletions(-)

-- 
2.21.0

