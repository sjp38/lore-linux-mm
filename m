Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDDFEC282CC
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 16:24:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 821372186A
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 16:24:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 821372186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 132498E00CB; Wed,  6 Feb 2019 11:24:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B86D8E00B1; Wed,  6 Feb 2019 11:24:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E9BCE8E00CB; Wed,  6 Feb 2019 11:24:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A348F8E00B1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 11:24:01 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id t72so5540234pfi.21
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 08:24:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8sR35CaedI4Qs66cpbyN62oC46EcvLGVfVMLRJrerx0=;
        b=c4KwTgFgRWNOHjuM3USLEKvXCbps1X4PDr1hioaDbLumlJO1EyaKAENED44F2dQKRn
         EpMabEBOCdDAhw5pU8hw93j9B9pBLDb9qJcQ5G3afjrmRRea+eeE5lZQfdv+Fdbgn/f4
         qzZ5WwXacpjxknt6cPBt4g5pUJ4sFlNkNxHTZsWO2bf0bMKdt+OMrZ1UeNwmqv/qvg/a
         fo7qi9qYcb/5xdYErhp18Rtgn7qke4hI3AYwBh75eKKF3bwkETKn/6yF2soG1Rrgtoy7
         iZfDSjXDcAkmHBsbB1Hcmeh1fXzvOjCtyemkCcAAHCYJZwFiC3rBwReFz816ShhAfpbe
         T+Og==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of srs0=f26y=qn=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=f26Y=QN=goodmis.org=rostedt@kernel.org"
X-Gm-Message-State: AHQUAubzLdUCmS8NQ4tqyEWItQyMX5uCBuZvG5qc82CQmfrzg+CxpNrC
	/T47jchtL1EUfyjtEI2BKBsqH9EDRlk5lwjSDdp2FF/o/C9dUT4YfU9fqZRJIquoqOe5s6Rl3wr
	4SKq2BoRQH57Mhd+ul1ZAkxSOvWvfFX8/xib7545c7BxSwjrH3eQ0O3e3PqQacOU=
X-Received: by 2002:a63:1d1d:: with SMTP id d29mr10395025pgd.49.1549470241302;
        Wed, 06 Feb 2019 08:24:01 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbiEqylFyr0XmmDg8hlYXQmMQti8py/dr/AZ+qK2ye5TFIMljARYG5gng0IXqNVC3DXr8PQ
X-Received: by 2002:a63:1d1d:: with SMTP id d29mr10394957pgd.49.1549470240313;
        Wed, 06 Feb 2019 08:24:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549470240; cv=none;
        d=google.com; s=arc-20160816;
        b=wh3GLFQSZAGmrBIHkfE/5oxVU6bDsXB831Q4oCERDKVTeHuvnQYoJYClG03sK/7MmJ
         L5lHFfIg155ozBE3gIMW9yS3z77Aq92lseNmcDdv4iy0gzr7DMIFmxyPMtBJx1wNTcZ5
         FgeqcUqf8mXouPLGqogj3QBf7OlUp3JlnnhuvAyvPXd9zR37xQckFuW0n5XJGGKCSYbj
         BwM0+MGx7UO37pU32hIYcosMDp+PhxCWmBTkjiKaa0Yqb247ISj8GDU8gAixN/4pQk8X
         jg/YuBoFzRFqBz1G8DRe4GinhucjoWTV6+0A6TJ+pKjtoBpjcQGDlRClC9d3Q+0G8hkb
         ESeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=8sR35CaedI4Qs66cpbyN62oC46EcvLGVfVMLRJrerx0=;
        b=btmGSshxIjZjJUC6WG2Pscy4EBVNRS+MhToU+226qYLnanpUVB2P9EFO1eOtV4w4c2
         byRX3GKv3YZpnB+JfVXKAZdrBC10yzBN/v3SWiUC8sOAyV1QvSu2m6d1Us0HvO3xXSis
         0Gsln+8FijNPmtTzEhkuhUO7RcfvS34pNFHieR5ec3sgENOtaipNhiVPhry9HL6wh9rk
         DDI8qCKnvy4KZzp8m6dyTAcXyWXD34S+A57q45cjjcMJzGLjdagtVXZ94Mt8es1jHjgm
         2zj0xRLF6IqOAjJeiLS25x4sR5zYYHkQrxh6YzzE5d1s+55W3Gv0EMLNKfLMV3nXiVrV
         YduA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of srs0=f26y=qn=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=f26Y=QN=goodmis.org=rostedt@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q4si2521199pfq.56.2019.02.06.08.24.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 08:24:00 -0800 (PST)
Received-SPF: pass (google.com: domain of srs0=f26y=qn=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of srs0=f26y=qn=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=f26Y=QN=goodmis.org=rostedt@kernel.org"
Received: from gandalf.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C72892175B;
	Wed,  6 Feb 2019 16:23:57 +0000 (UTC)
Date: Wed, 6 Feb 2019 11:23:56 -0500
From: Steven Rostedt <rostedt@goodmis.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>,
 linux-kernel@vger.kernel.org, x86@kernel.org, hpa@zytor.com, Thomas
 Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Nadav Amit
 <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Peter
 Zijlstra <peterz@infradead.org>, linux_dti@icloud.com,
 linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org,
 akpm@linux-foundation.org, kernel-hardening@lists.openwall.com,
 linux-mm@kvack.org, will.deacon@arm.com, ard.biesheuvel@linaro.org,
 kristen@linux.intel.com, deneen.t.dock@intel.com, Rusty Russell
 <rusty@rustcorp.com.au>, Masami Hiramatsu <mhiramat@kernel.org>, Daniel
 Borkmann <daniel@iogearbox.net>, Alexei Starovoitov <ast@kernel.org>,
 Jessica Yu <jeyu@kernel.org>, "Paul E . McKenney" <paulmck@linux.ibm.com>
Subject: Re: [PATCH 16/17] Plug in new special vfree flag
Message-ID: <20190206112356.64cc5f0d@gandalf.local.home>
In-Reply-To: <20190117003259.23141-17-rick.p.edgecombe@intel.com>
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
	<20190117003259.23141-17-rick.p.edgecombe@intel.com>
X-Mailer: Claws Mail 3.16.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 16 Jan 2019 16:32:58 -0800
Rick Edgecombe <rick.p.edgecombe@intel.com> wrote:

> Add new flag for handling freeing of special permissioned memory in vmalloc
> and remove places where memory was set RW before freeing which is no longer
> needed.
> 
> In kprobes, bpf and ftrace this just adds the flag, and removes the now
> unneeded set_memory_ calls before calling vfree.
> 
> In modules, the freeing of init sections is moved to a work queue, since
> freeing of RO memory is not supported in an interrupt by vmalloc.
> Instead of call_rcu, it now uses synchronize_rcu() in the work queue.
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Masami Hiramatsu <mhiramat@kernel.org>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: Jessica Yu <jeyu@kernel.org>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Cc: Paul E. McKenney <paulmck@linux.ibm.com>
> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
> ---
>  arch/x86/kernel/ftrace.c       |  6 +--

For the ftrace code.

Acked-by: Steven Rostedt (VMware) <rostedt@goodmis.org>

-- Steve

>  arch/x86/kernel/kprobes/core.c |  7 +---
>  include/linux/filter.h         | 16 ++-----
>  kernel/bpf/core.c              |  1 -
>  kernel/module.c                | 77 +++++++++++++++++-----------------
>  5 files changed, 45 insertions(+), 62 deletions(-)
>

