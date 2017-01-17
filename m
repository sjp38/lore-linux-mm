Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8F5B16B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 11:23:37 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id i68so90410648uad.3
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 08:23:37 -0800 (PST)
Received: from bugs.linux-mips.org (eddie.linux-mips.org. [2a01:4f8:201:92aa::3])
        by mx.google.com with ESMTP id q15si16941319qtb.214.2017.01.17.08.23.36
        for <linux-mm@kvack.org>;
        Tue, 17 Jan 2017 08:23:36 -0800 (PST)
Received: from localhost.localdomain ([127.0.0.1]:35306 "EHLO linux-mips.org"
        rhost-flags-OK-OK-OK-FAIL) by eddie.linux-mips.org with ESMTP
        id S23993890AbdAQQXfqVoMk (ORCPT <rfc822;linux-mm@kvack.org>);
        Tue, 17 Jan 2017 17:23:35 +0100
Date: Tue, 17 Jan 2017 17:23:29 +0100
From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 1/30] mm: Export init_mm for MIPS KVM use of pgd_alloc()
Message-ID: <20170117162329.GC24215@linux-mips.org>
References: <cover.d6d201de414322ed2c1372e164254e6055ef7db9.1483665879.git-series.james.hogan@imgtec.com>
 <a8df39719fb0570cb38e3fbb5c128fe2618e92d6.1483665879.git-series.james.hogan@imgtec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a8df39719fb0570cb38e3fbb5c128fe2618e92d6.1483665879.git-series.james.hogan@imgtec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Hogan <james.hogan@imgtec.com>
Cc: linux-mips@linux-mips.org, linux-mm@kvack.org, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, kvm@vger.kernel.org

On Fri, Jan 06, 2017 at 01:32:33AM +0000, James Hogan wrote:

> Export the init_mm symbol to GPL modules so that MIPS KVM can use
> pgd_alloc() to create GVA page directory tables for trap & emulate mode,
> which runs guest code in user mode. On MIPS pgd_alloc() is implemented
> inline and refers to init_mm in order to copy kernel address space
> mappings into the new page directory.

Ackedy-by: Ralf Baechle <ralf@linux-mips.org>

  Ralf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
