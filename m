Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8021FC10F01
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 18:41:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 451AB21902
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 18:41:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 451AB21902
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2C188E0003; Mon, 18 Feb 2019 13:41:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB0B58E0002; Mon, 18 Feb 2019 13:41:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B79E28E0003; Mon, 18 Feb 2019 13:41:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 714458E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:41:45 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id s16so5839348plr.1
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 10:41:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=B4bDvlBZiS8a1E/QmB4toGXSURXa1/kcqzmWW0VUdvY=;
        b=Fs2l3CHHCH6GDEU4qljx/qYFlZFwBadiT8eZe29gOhImJt7IiEOZp7kutIvduJ+QxG
         izuE/CARMBDZH+HwQNuC4iUAeEAsXscDRKePpIS/0xOrfVzr/A+DCMlIUQXu6NLEmlGU
         JfiJKGa9x/x1rjS90vBfjuzPwTZU/6cUbnYnwND8jos8oRaVgGZdQ0HF8RoPbk8lF9Cj
         osyYlqRAZdhhXKwxf05Xr2IqtpJeOQKTSIw1Pg7nZ9KUxmMMEkG7bdkjSXv1sqCMbqn0
         zJ3ka5Iy5QgXv4lIdVoKWHOsj9awIUIVNjEuIXRv5aqu44IAJcJW34P5Gfb60PhbiF1V
         Zozg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuaaa/nRE1S621LCuDBT861i3LkL6waJg7qlJN0FaJOfd0vrXBbd
	q4TLNoE2hlEFBPav0sBdu6XlMQlulXDZHoIvlwyEZA9CIKIM4/XRrpVu7E9F76n4uv7H0G+W6sr
	Q89y2cg5aT+n1O7anPcW6AXnXiuqzVLQf0FPCpiTfLJtKzyOdDNKG88n9hcNzXP3CMg==
X-Received: by 2002:a65:4101:: with SMTP id w1mr20282645pgp.257.1550515305057;
        Mon, 18 Feb 2019 10:41:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbI68sUM4zjTSoMkojadvAvny/NcEtwcRIND0HJYYe5X3pbZWom2dyU8x73zG5m+mgh7PA5
X-Received: by 2002:a65:4101:: with SMTP id w1mr20282588pgp.257.1550515304103;
        Mon, 18 Feb 2019 10:41:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550515304; cv=none;
        d=google.com; s=arc-20160816;
        b=q/8Ch37IEDlaYApqRMqBFiRZrx83PfF/UvgvCyw9yWb26XYs66n8ByodQngRbZeYrd
         Ns7t2C/zwrEw2di8b4tV2ubWr4nzUGFmHWhkRztErohX6gvoMZI4ijw4R7JCWk9LL0k0
         osfqLUnPcz07awsEYT0PagWO605Fyyf2dV81kICqgIRPwpoVxtLX0MBBm4gf0NrV/7Zv
         jexmApPsTy3Tv22nkWyzamw17/lBPs1PRXORuDdYA9K3nNc+aBJ9qyserStrC3Mr6QNd
         fApd9e9P7BbaviaKdOTP/Lm6xt6WEAuaMxmNqAVCqcziYuCnCnUFJE6Oh8sCrwSQZ8DV
         oM1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=B4bDvlBZiS8a1E/QmB4toGXSURXa1/kcqzmWW0VUdvY=;
        b=g65ATPqXp9pp/J+tXJu8VnKR95DZmuvlrG61wuL575pyvbFJrCo1+XOQmL32ZJdDKH
         t+IOHrvCu1TL/QCBAk7jzSKIgxbbQ3zbtUCjQFyuSyacSETW8BEmAkspMz9E56ozVBYe
         EhUjBabBhVNp1U/8fDe5daELHV2qZAcKeDGP//bnQF5bjx/oBMsD7srX1rjknwwqCKth
         FoEaDs5iufjupT4kWM1oOw2Y8n5yTMlQQI7mIsZfl1H3CWrMCZWgJL84nIsGeqhkTnqf
         drBrNI1ozCkyiZkFofitInaEetsxE7D+kZx5zbjHuUC6eM6gDXWXeBavq5H5NeLQjoCQ
         gy0w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 33si14087420ply.312.2019.02.18.10.41.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 10:41:44 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1IIcqkq064943
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:41:43 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qr1r6hb46-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:41:42 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 18 Feb 2019 18:41:40 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 18 Feb 2019 18:41:36 -0000
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1IIfaTR26017832
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 18 Feb 2019 18:41:36 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id ED5435204E;
	Mon, 18 Feb 2019 18:41:35 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.207.239])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTPS id B636952063;
	Mon, 18 Feb 2019 18:41:28 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Mon, 18 Feb 2019 20:41:26 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Palmer Dabbelt <palmer@sifive.com>,
        Richard Kuo <rkuo@codeaurora.org>, linux-arch@vger.kernel.org,
        linux-hexagon@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, linux-riscv@lists.infradead.org,
        Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH v2 0/4] provide a generic free_initmem implementation
Date: Mon, 18 Feb 2019 20:41:21 +0200
X-Mailer: git-send-email 2.7.4
X-TM-AS-GCONF: 00
x-cbid: 19021818-4275-0000-0000-00000310F3DF
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021818-4276-0000-0000-0000381F1D9A
Message-Id: <1550515285-17446-1-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-18_14:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=810 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902180138
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000132, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Many architectures implement free_initmem() in exactly the same or very
similar way: they wrap the call to free_initmem_default() with sometimes
different 'poison' parameter.

These patches switch those architectures to use a generic implementation
that does free_initmem_default(POISON_FREE_INITMEM).

This was inspired by Christoph's patches for free_initrd_mem [1] and I
shamelessly copied changelog entries from his patches :)

v2: rebased on top of v5.0-rc7 + Christoph's patches for free_initrd_mem

[1] https://lore.kernel.org/lkml/20190213174621.29297-1-hch@lst.de/

Mike Rapoport (4):
  init: provide a generic free_initmem implementation
  hexagon: switch over to generic free_initmem()
  init: free_initmem: poison freed init memory
  riscv: switch over to generic free_initmem()

 arch/alpha/mm/init.c      |  6 ------
 arch/arc/mm/init.c        |  8 --------
 arch/c6x/mm/init.c        |  5 -----
 arch/h8300/mm/init.c      |  6 ------
 arch/hexagon/mm/init.c    | 10 ----------
 arch/microblaze/mm/init.c |  5 -----
 arch/nds32/mm/init.c      |  5 -----
 arch/nios2/mm/init.c      |  5 -----
 arch/openrisc/mm/init.c   |  5 -----
 arch/riscv/mm/init.c      |  5 -----
 arch/sh/mm/init.c         |  5 -----
 arch/sparc/mm/init_32.c   |  5 -----
 arch/unicore32/mm/init.c  |  5 -----
 arch/xtensa/mm/init.c     |  5 -----
 init/main.c               |  5 +++++
 15 files changed, 5 insertions(+), 80 deletions(-)

-- 
2.7.4

