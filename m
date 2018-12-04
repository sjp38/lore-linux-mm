Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 78CD56B6DF7
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 04:25:55 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id n17so13469775pfk.23
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 01:25:55 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s17si14886562pgi.513.2018.12.04.01.25.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Dec 2018 01:25:54 -0800 (PST)
Date: Tue, 4 Dec 2018 10:25:50 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
Message-ID: <20181204092550.GT11614@hirez.programming.kicks-ass.net>
References: <cover.1543903910.git.alison.schofield@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1543903910.git.alison.schofield@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alison Schofield <alison.schofield@intel.com>
Cc: dhowells@redhat.com, tglx@linutronix.de, jmorris@namei.org, mingo@redhat.com, hpa@zytor.com, bp@alien8.de, luto@kernel.org, kirill.shutemov@linux.intel.com, dave.hansen@intel.com, kai.huang@intel.com, jun.nakajima@intel.com, dan.j.williams@intel.com, jarkko.sakkinen@intel.com, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On Mon, Dec 03, 2018 at 11:39:47PM -0800, Alison Schofield wrote:
> (Multi-Key Total Memory Encryption)

I think that MKTME is a horrible name, and doesn't appear to accurately
describe what it does either. Specifically the 'total' seems out of
place, it doesn't require all memory to be encrypted.
