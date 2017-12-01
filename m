Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 556A36B0253
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 10:31:39 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id m9so7605545pff.0
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 07:31:39 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id w8si4923639pgr.349.2017.12.01.07.31.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Dec 2017 07:31:38 -0800 (PST)
Subject: Re: KAISER: kexec triggers a warning
References: <03012d01-4d04-1d58-aa93-425f142f9292@canonical.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <84c7dd7d-5e01-627e-6f26-5c1e30a87683@linux.intel.com>
Date: Fri, 1 Dec 2017 07:31:36 -0800
MIME-Version: 1.0
In-Reply-To: <03012d01-4d04-1d58-aa93-425f142f9292@canonical.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juerg Haefliger <juerg.haefliger@canonical.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mingo@kernel.org, tglx@linutronix.de, peterz@infradead.org, hughd@google.com, luto@kernel.org

On 12/01/2017 05:52 AM, Juerg Haefliger wrote:
> Loading a kexec kernel using today's linux-tip master with KAISER=y
> triggers the following warning:
> 
> [   18.054017] ------------[ cut here ]------------
> [   18.054024] WARNING: CPU: 0 PID: 1183 at
> ./arch/x86/include/asm/pgtable_64.h:258 native_set_p4d+0x5f/0x80
> [   18.054025] Modules linked in: nls_utf8 isofs ppdev nls_iso8859_1
> kvm_intel kvm irqbypass input_leds serio_raw i2c_piix4 parport_pc
> parport qemu_fw_cfg mac_hid 9p fscache ib_iser rdma_cm iw_cm ib_cm

This is kexec is messing with PTEs that map the kernel, which is OK for
kexec to do.  The warning is harmless.

The only question is whether we want to preserve _some_ kind of warning
there, or just axe it entirely.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
