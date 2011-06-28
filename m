Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 4B5976B0116
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 13:10:46 -0400 (EDT)
Received: from mail-vx0-f169.google.com (mail-vx0-f169.google.com [209.85.220.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p5SHAEjZ019970
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 10:10:15 -0700
Received: by vxg38 with SMTP id 38so448784vxg.14
        for <linux-mm@kvack.org>; Tue, 28 Jun 2011 10:10:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110628165303.010143380@goodmis.org>
References: <20110628164750.281686775@goodmis.org> <20110628165303.010143380@goodmis.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 28 Jun 2011 10:02:15 -0700
Message-ID: <BANLkTikgxKNx1eyR1m6NpVA5Ykfduzq-Mw@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: Document handle_mm_fault()
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Russell King <rmk+kernel@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Gleb Natapov <gleb@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Avi Kivity <avi@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>

On Tue, Jun 28, 2011 at 9:47 AM, Steven Rostedt <rostedt@goodmis.org> wrote=
:
> + * Note: if @flags has FAULT_FLAG_ALLOW_RETRY set then the mmap_sem
> + * =A0 =A0 =A0 may be released if it failed to arquire the page_lock. If=
 the
> + * =A0 =A0 =A0 mmap_sem is released then it will return VM_FAULT_RETRY s=
et.
> + * =A0 =A0 =A0 This is to keep the time mmap_sem is held when the page_l=
ock
> + * =A0 =A0 =A0 is taken for IO.

So I know what that flag does, but I knew it without the comment.

WITH the comment, I'm just confused. "This is to keep the time
mmap_sem is held when the page_lock is taken for IO."

Sounds like a google translation from swahili. "keep the time" what?

Maybe "keep" -> "minimize"? Or just "This is to avoid holding mmap_sem
while waiting for IO"

                        Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
