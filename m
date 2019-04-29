Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C61EC43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 19:58:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE3662075E
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 19:58:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="Oujy3vVT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE3662075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=wdc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 653876B000E; Mon, 29 Apr 2019 15:58:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 510FB6B000C; Mon, 29 Apr 2019 15:58:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DB7A6B000D; Mon, 29 Apr 2019 15:58:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 012766B0008
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 15:58:30 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id a8so7750954pgq.22
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 12:58:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:ironport-sdr:ironport-sdr:from:to
         :cc:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WtBjYoAHkWUE+EmE+Dj18Yw6Y6txgDPtaMz1TSW2Pbs=;
        b=q2GDtuqEqEn9fbP67LFyUFdeR+vZSp3hyfReXDEGH0OTJ1GeWefMLog/Iyx7qqT2A2
         idtMDrhaXT3KXTSVKDt73JiEXE2SZu0TyHf1d3PEDV/bxKZ06hMSAl5MRQNATLNL3it5
         PZmpnAx1B+0hHvH3raU8JcB4D0+2693e/luR55guWeH6/6U7/9XLJopTr1BiZVa90sJ8
         roWwc9MtTtsNcqpCYmO0Ir22APmGzaQpc7rL71nKUiJ3mnjgAgxoN9aLhEXWSlDFFvnZ
         e5eGncVW8Ub+PqrRQAxxS+fK+lG83PJEFNC4as4SnYe8nPN/aLE2rD2VWp5Frd4dpDVS
         lazw==
X-Gm-Message-State: APjAAAXpsekeRz/yq520rogEsM1BrQh/Sl5A8DN8YNTNb9y8bL50Gknn
	XjkBISwlCtwb1OkyituqJyfljcGFh/UzoB4RKWfgn7wPEomvMZkZq6bhl5Uhw623xVw+AK22n8f
	z5R4kIflTXfbdPujz6CFDGP1VydeKF/K5LrzJLXsJAGPcCcYhOYzJd5L5MqX9gVHVMQ==
X-Received: by 2002:a63:fa46:: with SMTP id g6mr61965016pgk.382.1556567909651;
        Mon, 29 Apr 2019 12:58:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxw/codt//0Vd3/xSG19TA6mxHGMgwzNW43pvhR2YfDSspgjGvtiPJlRTUNlYoWAAVmj3bR
X-Received: by 2002:a63:fa46:: with SMTP id g6mr61964931pgk.382.1556567908793;
        Mon, 29 Apr 2019 12:58:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556567908; cv=none;
        d=google.com; s=arc-20160816;
        b=EwzKVlq9baxFBF22u24amiehSl3STpLHUY9ahIo9pC6hRrz7NTI2MI0Ylb+66rgQZ4
         cz5DhE94TXu26JG5GQ0WQZSbtz1csTucTgwFxg0aGqgjtbSPYeLy4xzdfiFT73ImV4UZ
         jD/uhr49zKKZZ1wkNstGZ+bg0VKD30jmPoGZilGE1iKcPa/ysZhHxU5yzxSjumITeoYp
         qszTJ3wEBigIveLmyrA2rBazMcuI2YWbdyFHxXooNKWeCwaH3lbuA5jN3OgO2Jqj7AGB
         o0QYmjM74pVIzuEdgvO1XixooNAX7rdFtGBipkGL6UcXY6zQfM2NVa850Q9QHfXykAZ7
         Hxyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:ironport-sdr:ironport-sdr
         :dkim-signature;
        bh=WtBjYoAHkWUE+EmE+Dj18Yw6Y6txgDPtaMz1TSW2Pbs=;
        b=EICu5HqT3j9KgS0SErvQiskMBwvfqMkML82drzSMR7uo+2qUeOlwu9rs+hqh3kBXPw
         VtcMu6eGMozv5NIYNJ7gqjSZBJNcY446Mt9En9m1QCkyxeykuhfjpFi/XrMmdDO0A7bo
         P2PZpRt2FXv4wQFBzWmnkaR+k72F4GRLks7Lim/7DgOF6Wlh6uS1jNaaylYxWc3RCPrB
         ii8z5gLToIKWbJjmdiQS9RuI636ApLaNg/dzD8AYW1vaFpzf0g4TMSzMKwKod3sFu7Al
         NXgvxo06DAc3g2xCJUkeJ9700WdHDCn5w+D8tDzq6QzrtfruQvXipRFGQQ7FlbAs+ETr
         pO8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=Oujy3vVT;
       spf=pass (google.com: domain of prvs=0155011cf=atish.patra@wdc.com designates 68.232.141.245 as permitted sender) smtp.mailfrom="prvs=0155011cf=atish.patra@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
Received: from esa1.hgst.iphmx.com (esa1.hgst.iphmx.com. [68.232.141.245])
        by mx.google.com with ESMTPS id c3si34040478plo.243.2019.04.29.12.58.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 12:58:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0155011cf=atish.patra@wdc.com designates 68.232.141.245 as permitted sender) client-ip=68.232.141.245;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=Oujy3vVT;
       spf=pass (google.com: domain of prvs=0155011cf=atish.patra@wdc.com designates 68.232.141.245 as permitted sender) smtp.mailfrom="prvs=0155011cf=atish.patra@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1556567908; x=1588103908;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=674EX0iIftC/tP47ciQ2WAq8p0Blf4MJzfJ6YEpD/54=;
  b=Oujy3vVTrTYWAj/seY8BIy620epPPCi27Y81ZFx7zhOATMEbRe8Z/lFC
   oxprWO7nSt6o0n5pcbLH0xIq0Ve8a/gOj7r6Mq/o2RNQiA7iqxWykTYko
   iHuMrMdCQbSURqtLV6viI6/pzdW5mM/l606ect5F4XlPPE65sD/vY+xWL
   GrF2WxsyMy92m4n/YxMeVeBb+gbQnhr4pyuP5wSe682/4U5xdAsbhQgfO
   RRwTJclLb0MLrHZI/Ea8n5u62gQdEoco/LQ6jtuEs5l5fOAGI+AkjuWKS
   VSfnKc9XAqlImViAorgYHo30XsLG+T7+rPHLJ36Mjr+r5uARZGs9DQZMV
   A==;
X-IronPort-AV: E=Sophos;i="5.60,410,1549900800"; 
   d="scan'208";a="212999881"
Received: from h199-255-45-14.hgst.com (HELO uls-op-cesaep01.wdc.com) ([199.255.45.14])
  by ob1.hgst.iphmx.com with ESMTP; 30 Apr 2019 03:58:12 +0800
IronPort-SDR: KuWhFv47et2z13s4ogsFydIuOHEUFbDE1H5YHCXxj4NfDq+KZzHYEVEcJQMz8xQKW9eH9uPC8A
 z50hSxMrHZud/+caVvYrkOs4WRFbqPfjdP8E5fiUv3LR80IKCHZ8SYZaqEbKIpoqY2AP6PEBcl
 cRKd9qF/baH9E304gOpH2aQ4FKzoAmmLKDwcBhY3GWBx0CJHd7JQkkEU4X0rEdRx8ZaURLE0Li
 odbp1pAhWh7W6nO/ewOr5Uywt+3wrsZ86wR0lhuqaI0qRA0NdPOBxWmnkXvmocrIiMOx6eTWFr
 pCKDGT6RqUPItX+jWyHzkvWj
Received: from uls-op-cesaip01.wdc.com ([10.248.3.36])
  by uls-op-cesaep01.wdc.com with ESMTP; 29 Apr 2019 12:34:35 -0700
IronPort-SDR: Bt0jcdD1gm6d1cRvYD8xLZ7OUU/7ALDxMP8bBhd/gEWwUm0ZOsyuoXKhnV/Htgbmrf1RFmzG5a
 KdmEWUvthppVLvTA/Wn2Wuh9DNVRFYVw78A+JrkdrPf+GhM2TyGnTWr7XZAa/3XETeB0z6VmGW
 Nr8nyyN1U1289sezewNwGRjArVhMrC560i55lAnYqYS4xUqANmVFYO1xUWVEonuy8UVyPN4UZY
 SpvkvHtvLuG2nrfaNqKYpDrYj+YxmwOv76nBf9H3mxnpjf3yRS75QhSJzUH0vhLsZUtfAEVqHj
 T54=
Received: from jedi-01.sdcorp.global.sandisk.com (HELO jedi-01.int.fusionio.com) ([10.11.143.218])
  by uls-op-cesaip01.wdc.com with ESMTP; 29 Apr 2019 12:58:11 -0700
From: Atish Patra <atish.patra@wdc.com>
To: linux-kernel@vger.kernel.org
Cc: Atish Patra <atish.patra@wdc.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Anup Patel <anup@brainfault.org>,
	Borislav Petkov <bp@alien8.de>,
	Changbin Du <changbin.du@intel.com>,
	Gary Guo <gary@garyguo.net>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	linux-mm@kvack.org,
	linux-riscv@lists.infradead.org,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Palmer Dabbelt <palmer@sifive.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Vlastimil Babka <vbabka@suse.cz>,
	x86@kernel.org (maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)),
	Christoph Hellwig <hch@infradead.org>
Subject: [PATCH v2 2/3] RISC-V: Enable TLBFLUSH counters for debug kernel.
Date: Mon, 29 Apr 2019 12:57:58 -0700
Message-Id: <20190429195759.18330-3-atish.patra@wdc.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190429195759.18330-1-atish.patra@wdc.com>
References: <20190429195759.18330-1-atish.patra@wdc.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The TLB flush counters under vmstat seems to be very helpful while
debugging TLB flush performance in RISC-V.

Add the Kconfig option only for debug kernels.

Signed-off-by: Atish Patra <atish.patra@wdc.com>
---
 arch/riscv/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/riscv/Kconfig b/arch/riscv/Kconfig
index eb56c82d8aa1..c1ee876d1e7f 100644
--- a/arch/riscv/Kconfig
+++ b/arch/riscv/Kconfig
@@ -49,6 +49,7 @@ config RISCV
 	select GENERIC_IRQ_MULTI_HANDLER
 	select ARCH_HAS_PTE_SPECIAL
 	select HAVE_EBPF_JIT if 64BIT
+	select HAVE_ARCH_DEBUG_TLBFLUSH if DEBUG_KERNEL
 
 config MMU
 	def_bool y
-- 
2.21.0

