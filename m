Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 545EC6B6DF7
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 04:22:15 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id b21so3874032ioj.8
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 01:22:15 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id l187si9628983iof.132.2018.12.04.01.22.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Dec 2018 01:22:14 -0800 (PST)
Date: Tue, 4 Dec 2018 10:22:10 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC v2 12/13] keys/mktme: Save MKTME data if kernel cmdline
 parameter allows
Message-ID: <20181204092209.GS11614@hirez.programming.kicks-ass.net>
References: <cover.1543903910.git.alison.schofield@intel.com>
 <c2668d6d260bff3c88440ad097eb1445ea005860.1543903910.git.alison.schofield@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c2668d6d260bff3c88440ad097eb1445ea005860.1543903910.git.alison.schofield@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alison Schofield <alison.schofield@intel.com>
Cc: dhowells@redhat.com, tglx@linutronix.de, jmorris@namei.org, mingo@redhat.com, hpa@zytor.com, bp@alien8.de, luto@kernel.org, kirill.shutemov@linux.intel.com, dave.hansen@intel.com, kai.huang@intel.com, jun.nakajima@intel.com, dan.j.williams@intel.com, jarkko.sakkinen@intel.com, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On Mon, Dec 03, 2018 at 11:39:59PM -0800, Alison Schofield wrote:
> Change-Id: If57414862f1ac131dd97e29bf4f3937ac33777f6

Does not belong in patches..
