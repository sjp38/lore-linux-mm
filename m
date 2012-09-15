Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 48FE36B005D
	for <linux-mm@kvack.org>; Sat, 15 Sep 2012 03:52:06 -0400 (EDT)
Received: by weys10 with SMTP id s10so3430122wey.14
        for <linux-mm@kvack.org>; Sat, 15 Sep 2012 00:52:04 -0700 (PDT)
Message-ID: <505433A0.3010702@suse.cz>
Date: Sat, 15 Sep 2012 09:52:00 +0200
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 6/7] mm: add CONFIG_DEBUG_VM_RB build option
References: <1346750457-12385-1-git-send-email-walken@google.com> <1346750457-12385-7-git-send-email-walken@google.com> <5053AC2F.3070203@gmail.com> <CANN689Ff3W4z=+3J8aGO-2GrPHGJ=ote_f5q9jzRQRAP+b0T4Q@mail.gmail.com> <20120915000029.GA29426@google.com>
In-Reply-To: <20120915000029.GA29426@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, linux-mm@kvack.org, riel@redhat.com, peterz@infradead.org, aarcange@redhat.com, hughd@google.com, daniel.santos@pobox.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Dave Jones <davej@redhat.com>

On 09/15/2012 02:00 AM, Michel Lespinasse wrote:
> All right. Hugh managed to reproduce the issue on his suse laptop, and
> I came up with a fix.
> 
> The problem was that in mremap, the new vma's vm_{start,end,pgoff}
> fields need to be updated before calling anon_vma_clone() so that the
> new vma will be properly indexed.
> 
> Patch attached. I expect this should also explain Jiri's reported
> failure involving splitting THP pages during mremap(), even though we
> did not manage to reproduce that one.

Oh, great. This is BTW also machine with suse. What was the way that
Hugh used to reproduce the other issue? For me it happened twice in a
row when using zypper to upgrade packages. But it did not happen any
more after that.

thanks,
-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
