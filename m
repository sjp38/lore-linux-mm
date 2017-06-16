Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6893D6B0279
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 06:58:59 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g46so7005082wrd.3
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 03:58:59 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id i14si1925025wrc.136.2017.06.16.03.58.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 03:58:58 -0700 (PDT)
Date: Fri, 16 Jun 2017 12:58:55 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH tip/sched/core] mm/early_ioremap: Adjust early_ioremap
 system_state check
In-Reply-To: <20170614191152.28089.65392.stgit@tlendack-t1.amdoffice.net>
Message-ID: <alpine.DEB.2.20.1706161257250.2254@nanos>
References: <20170614191152.28089.65392.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@suse.de>, Ingo Molnar <mingo@kernel.org>

On Wed, 14 Jun 2017, Tom Lendacky wrote:
> A recent change added a new system_state value, SYSTEM_SCHEDULING, which
> exposed a warning issued by early_ioreamp() when the system_state was not
> SYSTEM_BOOTING. Since early_ioremap() can be called when the system_state
> is SYSTEM_SCHEDULING, the check to issue the warning is changed from
> system_state != SYSTEM_BOOTING to system_state >= SYSTEM_RUNNING.

Errm, why is that early_ioremap() stuff called after we enabled the
scheduler? At that point the regular ioremap stuff is long working.

Thanks,

	tglx


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
