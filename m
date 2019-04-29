Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9F22C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 19:58:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A5462075E
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 19:58:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="DFLYqn0r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A5462075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=wdc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B565B6B0007; Mon, 29 Apr 2019 15:58:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B058C6B0008; Mon, 29 Apr 2019 15:58:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A6B36B000A; Mon, 29 Apr 2019 15:58:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5F26D6B0007
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 15:58:29 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id q73so2237597pfi.17
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 12:58:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:ironport-sdr:ironport-sdr:from:to
         :cc:subject:date:message-id:mime-version:content-transfer-encoding;
        bh=u5AqppAW5Cwsnsx9ILViy9btcrQ6Cj1070bfIFAad+o=;
        b=Aau0TsSnYwfZzxQWhSqp6IyuKdwP4dIq22i7hyPcLVeyPUAoraVYyBqmtJRMjhVs2E
         AwaeoIot49M6ryayA3vVQ8Tk9408lstDBeML2gIGtpgHM/+bLDX6I2H7kgCAEyr5ncI7
         ZKlJMAcH7FRO2+GMHl/wK1qNCQwkJH9pDgmaXo73mhxU3R1+44lhMUI+8+kXEQZGvW+9
         KhbNwNZsXkPPpNhpH9+r4JQTOBK/Co2gvKWe8PdH4PrwETDOA2vLJG/63kABZjxATqCI
         Dfi+pLtnvPVOmWtUuY09SPxo2mu5YNt9M1zPzhY9BuJt1ccXxOX3tnfVwOAlJcHa2Vgj
         a2gw==
X-Gm-Message-State: APjAAAVF/imAK63oiQz/vqaRJF4hR9bQfssDRK6To6qBuLtdR9foLZoB
	gf7WPpQplLGVkE8K4tPDBYthew1YZPHf0SKNcxQSMOoc8IS5JID4JDUM0S6Ma5AhUjNTBE9dKXO
	puIQ1DZmRMxA83qufLm5UtGNyfSDczoX3SgKxyvvQHtX7WIXLwoNSOinSP68gQeBzTQ==
X-Received: by 2002:a17:902:163:: with SMTP id 90mr65097717plb.34.1556567908990;
        Mon, 29 Apr 2019 12:58:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwd5d00aEJgilrFEfcWehDUofb1E3RUYdnhbcMyzjEHu+wu24mWtMT6gw5lw6oiKqeLgGZs
X-Received: by 2002:a17:902:163:: with SMTP id 90mr65097637plb.34.1556567908177;
        Mon, 29 Apr 2019 12:58:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556567908; cv=none;
        d=google.com; s=arc-20160816;
        b=uIZ/wzr6+vdbevvapCUbVdW5xJa06SS83BHkDaC536f+jaGLU+1HCG8kgH2c2V0i4f
         sf+7FbpRe5oCX4Qq0dRmEPObtc3ISpamTNEAQ2xuE4e/zcndEK9RrAOzZEB9l3usfur1
         t8RhNxjO9kfj32QsL9lTqSOZqG//Cf51e1BEnxPpTbJ96++koMQu8gzs2xw8fS0MgzM/
         TD+1vgPwmzEPC87Vo5ziYmXrvsn6DnC15aaXzdkOc9Qate+cHwr8eclIpucd0tlCuQ49
         bvF9le2yDmZuBE7Rs5YLOHxp+cyLVz1mqJcXyX1AN/YudOFDugV8Y8GU7r+DTaiGNhXI
         xcLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:ironport-sdr:ironport-sdr:dkim-signature;
        bh=u5AqppAW5Cwsnsx9ILViy9btcrQ6Cj1070bfIFAad+o=;
        b=wOL4sfLb8rG6W1QLn7KvLYUIfoZGULjteqFeAUnegItTrRuWVH/MNYtHxiQYFEIOno
         9QTZn7UCQ+5RaFr6Fzj7TH3rbaz7lVLMxpDie+7P2oekMPOC/A8fvXZXKWjuJcMZ5EY+
         y6oSYe8rIFeYNujWcMAbBN0sHc553BikXS1Z+GcLB8Ftu84A3h5AzA1H9wvmYT91YRNh
         WxHHPpMTkiRDYqLbuNqxZLoP+WmGO4cjKDxSl/VWllEqLFNzKgOOw5So8wV3THAGXa/u
         8VlZwz9pXZNBaOuH2NcaliSklpUUKc9rJjbI4v0d0wsReV0MsRQoF5lW1I/EGhETqN94
         6Jsg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=DFLYqn0r;
       spf=pass (google.com: domain of prvs=0155011cf=atish.patra@wdc.com designates 68.232.141.245 as permitted sender) smtp.mailfrom="prvs=0155011cf=atish.patra@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
Received: from esa1.hgst.iphmx.com (esa1.hgst.iphmx.com. [68.232.141.245])
        by mx.google.com with ESMTPS id c3si34040478plo.243.2019.04.29.12.58.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 12:58:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0155011cf=atish.patra@wdc.com designates 68.232.141.245 as permitted sender) client-ip=68.232.141.245;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=DFLYqn0r;
       spf=pass (google.com: domain of prvs=0155011cf=atish.patra@wdc.com designates 68.232.141.245 as permitted sender) smtp.mailfrom="prvs=0155011cf=atish.patra@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1556567908; x=1588103908;
  h=from:to:cc:subject:date:message-id:mime-version:
   content-transfer-encoding;
  bh=GppUJ721qvDXD5FXETSpJUQwCmaDQ8dPUNFVqKinAfU=;
  b=DFLYqn0rH9onGnhfXjkELM18qdllLlvaYq5mkQ9NinZLvDK/z+2ka7+5
   Y2RbLjx4m2jrp1xc2XJE02TTYEnV5lV8h50m7/IgEvu0454r34ibPNLRB
   TrBAFYc6eeYBJV7eSHqtwIhxN193YbvV+EHNyvR2x1djK6eNG1+L/cjxi
   Uw0euUVD2WV9JTHbv8a+PW18seVBK7K3lHJzZMtyScORWLuR/ChJx61FG
   GCHD0Mz97IENzCqRQY78pMPFsdAmds8QX5Y6GIKx3m7RIlm6HQ+BaFAsA
   +iyGO+G+exk6Js4Uf20Cc0G7nvGBPJvl6QIgrordzHQA5JmPcj8q7LcOQ
   g==;
X-IronPort-AV: E=Sophos;i="5.60,410,1549900800"; 
   d="scan'208";a="212999864"
Received: from h199-255-45-14.hgst.com (HELO uls-op-cesaep01.wdc.com) ([199.255.45.14])
  by ob1.hgst.iphmx.com with ESMTP; 30 Apr 2019 03:58:11 +0800
IronPort-SDR: nZ5PcrQM5Ij6WVML8BpX0ZXDWD/R1tRvy+Y2W3efgTCt5X+43q/z+6fVhElvueiED2tyM2m7ES
 uzmccTvfB86xHL02MA3KSpW2EoP+7JcV0539CC7c3Ojzd7bnK+cMjJ8gCCJPtwG1AkuK/xww84
 TXEoy6CfK7FTj8McJoThfUWuywwbxANTsmdZmrylnUop0QoNcAUg9o9zHq7cq9+pVtCGHKw/Mp
 I/wIN7IsFrboInuaGSFBw35slS8Q46AF4+fgIkSRfICjD7hxa7crDnA1fZcLOA6QkVsmPGs8mH
 ohO/WGe6+8dXhGSQRvcHZeWP
Received: from uls-op-cesaip01.wdc.com ([10.248.3.36])
  by uls-op-cesaep01.wdc.com with ESMTP; 29 Apr 2019 12:34:34 -0700
IronPort-SDR: AGlb8C2mLL6BEh346K0F1Ldnycd8TuHmmHBt8swMOSQWKGcUOZ/GtOQDaFFXeORG/zWxkCgHXx
 nzJQlQIghVNQXnkEjAQOEQUPOjNCVQ5y1SBejZUGuuFp9B0eRtslW/zK8NGGjJDIQpFozyVeOM
 c1c2kGCUDOUVsq/h9Ge49ygnvU7TmuxYJwZ5n+rJO10fyN3/A7uhaldxaK15ZJIhvGQrq8VGJu
 nx6P8XoH9tIOdcny39PXJFO6BV+PcDuraWj9yW0XYNUyojx7wUvonwTJv9e1f8aixOeexoZ4Xf
 +80=
Received: from jedi-01.sdcorp.global.sandisk.com (HELO jedi-01.int.fusionio.com) ([10.11.143.218])
  by uls-op-cesaip01.wdc.com with ESMTP; 29 Apr 2019 12:58:10 -0700
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
Subject: [PATCH v2 0/3] TLB flush counters
Date: Mon, 29 Apr 2019 12:57:56 -0700
Message-Id: <20190429195759.18330-1-atish.patra@wdc.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The RISC-V patch (2/3) is based on Gary's TLB flush patch series

https://patchwork.kernel.org/project/linux-riscv/list/?series=97315

The x86 kconfig fix patch(1/3) can be applied separately.

Changes from v1->v2:
1. Move the arch specific config option to a common one as it touches
   generic code.
2. Introduced another config that architectures can select to enable
   tlbflush option.

Atish Patra (3):
x86: Move DEBUG_TLBFLUSH option.
RISC-V: Enable TLBFLUSH counters for debug kernel.
RISC-V: Update tlb flush counters

arch/riscv/Kconfig                |  1 +
arch/riscv/include/asm/tlbflush.h |  5 +++++
arch/riscv/mm/tlbflush.c          | 12 ++++++++++++
arch/x86/Kconfig                  |  1 +
arch/x86/Kconfig.debug            | 19 -------------------
mm/Kconfig.debug                  | 13 +++++++++++++
6 files changed, 32 insertions(+), 19 deletions(-)

--
2.21.0

