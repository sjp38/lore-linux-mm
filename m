Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B91C16B0280
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 01:47:32 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q7so16573852pgr.10
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 22:47:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 14si8194494pla.382.2017.11.27.22.47.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Nov 2017 22:47:31 -0800 (PST)
Subject: Re: [patch 2/4] x86/kaiser: Enable PARAVIRT again
References: <20171127203416.236563829@linutronix.de>
 <20171127204257.575052752@linutronix.de>
From: Juergen Gross <jgross@suse.com>
Message-ID: <3dd8ba26-aa52-9d8b-011c-24ff18ae2d56@suse.com>
Date: Tue, 28 Nov 2017 07:47:25 +0100
MIME-Version: 1.0
In-Reply-To: <20171127204257.575052752@linutronix.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On 27/11/17 21:34, Thomas Gleixner wrote:
> XEN_PV paravirtualizes read/write_c3. This does not work with KAISER as the
> CR3 switch from and to user space PGD would require to map the whole XEN_PV
> machinery into both. It's also not clear whether the register space is
> sufficient to do so. All other PV guests use the native implementations and
> are compatible with KAISER.
> 
> Add detection for XEN_PV and disable KAISER in the early boot process when
> the kernel is running as a XEN_PV guest.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

Reviewed-by: Juergen Gross <jgross@suse.com>


Juergen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
