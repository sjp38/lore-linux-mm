Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 684496B72C2
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 00:47:26 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id j8so4538610plb.1
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 21:47:26 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id u21si17102357pgg.463.2018.12.04.21.47.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 21:47:25 -0800 (PST)
Date: Tue, 4 Dec 2018 21:49:59 -0800
From: Alison Schofield <alison.schofield@intel.com>
Subject: Re: [RFC v2 04/13] x86/mm: Add helper functions for MKTME memory
 encryption keys
Message-ID: <20181205054959.GA18844@alison-desk.jf.intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
 <bd83f72d30ccfc7c1bc7ce9ab81bdf66e78a1d7d.1543903910.git.alison.schofield@intel.com>
 <20181204091434.GQ11614@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181204091434.GQ11614@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: dhowells@redhat.com, tglx@linutronix.de, jmorris@namei.org, mingo@redhat.com, hpa@zytor.com, bp@alien8.de, luto@kernel.org, kirill.shutemov@linux.intel.com, dave.hansen@intel.com, kai.huang@intel.com, jun.nakajima@intel.com, dan.j.williams@intel.com, jarkko.sakkinen@intel.com, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On Tue, Dec 04, 2018 at 10:14:34AM +0100, Peter Zijlstra wrote:
> On Mon, Dec 03, 2018 at 11:39:51PM -0800, Alison Schofield wrote:
> 
> CodingStyle
> CodingStyle
>
Thanks Peter. I'll repair all the badly nested if statements.
