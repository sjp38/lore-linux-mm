Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7F9796B0005
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 06:17:04 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k27-v6so8016812wre.23
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 03:17:04 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 140si912079wmi.146.2018.04.20.03.17.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 20 Apr 2018 03:17:03 -0700 (PDT)
Date: Fri, 20 Apr 2018 12:16:46 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 2/2] x86, pti: fix boot warning from Global-bit setting
In-Reply-To: <20180417211304.7B3F1FDB@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.21.1804201215170.1683@nanos.tec.linutronix.de>
References: <20180417211302.421F6442@viggo.jf.intel.com> <20180417211304.7B3F1FDB@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mceier@gmail.com, aaro.koskinen@nokia.com, aarcange@redhat.com, luto@kernel.org, arjan@linux.intel.com, bp@alien8.de, dan.j.williams@intel.com, dwmw2@infradead.org, gregkh@linuxfoundation.org, hughd@google.com, jpoimboe@redhat.com, jgross@suse.com, keescook@google.com, torvalds@linux-foundation.org, namit@vmware.com, peterz@infradead.org

On Tue, 17 Apr 2018, Dave Hansen wrote:

> 
> These are _very_ lightly tested.  I'm throwing them out there for
> folks are looking for a fix.
> 
> ---
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> pageattr.c is not friendly when it encounters empty (zero) PTEs.  The
> kernel linear map is exempt from these checks, but kernel text is not.
> This patch adds the code to also exempt kernel text from these checks.

Bah. Changelogs should tell the WHY and not the WHAT

> The proximate cause of these warnings was most likely an __init area
> that spanned a 2MB page boundary that resulted in a "zero" PMD.

This doesn't make any sense at all. 

Thanks,

	tglx
