Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 81DB08E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 08:21:48 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id q23so7432778ior.6
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 05:21:48 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id a26si846180ioc.100.2019.01.17.05.21.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 17 Jan 2019 05:21:46 -0800 (PST)
Date: Thu, 17 Jan 2019 14:21:26 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 00/17] Merge text_poke fixes and executable lockdowns
Message-ID: <20190117132126.GI10486@hirez.programming.kicks-ass.net>
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, hpa@zytor.com, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux_dti@icloud.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org, akpm@linux-foundation.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, will.deacon@arm.com, ard.biesheuvel@linaro.org, kristen@linux.intel.com, deneen.t.dock@intel.com



1-7,11-12

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
