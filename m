Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A32826B6E11
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 04:46:54 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id q63so11965859pfi.19
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 01:46:54 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id g11si15834534pgu.347.2018.12.04.01.46.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 01:46:53 -0800 (PST)
Date: Tue, 4 Dec 2018 12:46:47 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
Message-ID: <20181204094647.tjsvwjgp3zq6yqce@black.fi.intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
 <20181204092550.GT11614@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181204092550.GT11614@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Alison Schofield <alison.schofield@intel.com>, dhowells@redhat.com, tglx@linutronix.de, jmorris@namei.org, mingo@redhat.com, hpa@zytor.com, bp@alien8.de, luto@kernel.org, dave.hansen@intel.com, kai.huang@intel.com, jun.nakajima@intel.com, dan.j.williams@intel.com, jarkko.sakkinen@intel.com, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On Tue, Dec 04, 2018 at 09:25:50AM +0000, Peter Zijlstra wrote:
> On Mon, Dec 03, 2018 at 11:39:47PM -0800, Alison Schofield wrote:
> > (Multi-Key Total Memory Encryption)
> 
> I think that MKTME is a horrible name, and doesn't appear to accurately
> describe what it does either. Specifically the 'total' seems out of
> place, it doesn't require all memory to be encrypted.

MKTME implies TME. TME is enabled by BIOS and it encrypts all memory with
CPU-generated key. MKTME allows to use other keys or disable encryption
for a page.

But, yes, name is not good.

-- 
 Kirill A. Shutemov
