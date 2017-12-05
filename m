Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 650116B025E
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 07:18:20 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id c9so20587wrb.4
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 04:18:20 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e16si191178ede.427.2017.12.05.04.18.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Dec 2017 04:18:19 -0800 (PST)
Subject: Re: [patch 24/60] x86/paravirt: Dont patch flush_tlb_single
References: <20171204140706.296109558@linutronix.de>
 <20171204150606.828111617@linutronix.de>
From: Juergen Gross <jgross@suse.com>
Message-ID: <7baec44d-bcb9-37f8-f793-b632dd8776d5@suse.com>
Date: Tue, 5 Dec 2017 13:18:15 +0100
MIME-Version: 1.0
In-Reply-To: <20171204150606.828111617@linutronix.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Dave Hansen <dave.hansen@linux.intel.com>, michael.schwarz@iaik.tugraz.at, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On 04/12/17 15:07, Thomas Gleixner wrote:
> From: Thomas Gleixner <tglx@linutronix.de>
> 
> native_flush_tlb_single() will be changed with the upcoming
> KERNEL_PAGE_TABLE_ISOLATION feature. This requires to have more code in
> there than INVLPG.
> 
> Remove the paravirt patching for it.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Acked-by: Peter Zijlstra <peterz@infradead.org>
> Reviewed-by: Josh Poimboeuf <jpoimboe@redhat.com>

Reviewed-by: Juergen Gross <jgross@suse.com>


Juergen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
