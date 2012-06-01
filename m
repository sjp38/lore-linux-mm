Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id E0D156B004D
	for <linux-mm@kvack.org>; Thu, 31 May 2012 22:43:47 -0400 (EDT)
Received: by wefh52 with SMTP id h52so1399293wef.14
        for <linux-mm@kvack.org>; Thu, 31 May 2012 19:43:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120601023107.GA19445@redhat.com>
References: <20120530163317.GA13189@redhat.com> <20120531005739.GA4532@redhat.com>
 <20120601023107.GA19445@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 31 May 2012 19:43:25 -0700
Message-ID: <CA+55aFyNSUbTfY4YdH4OcrrRnwkw-sHy3aT18ynf-YXRXSJQ8Q@mail.gmail.com>
Subject: Re: WARNING: at mm/page-writeback.c:1990 __set_page_dirty_nobuffers+0x13a/0x170()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Cong Wang <amwang@redhat.com>

On Thu, May 31, 2012 at 7:31 PM, Dave Jones <davej@redhat.com> wrote:
>
> So I bisected it anyway, and it led to ...

Ok, that doesn't sound entirely unlikely, but considering that you're
nervous about the bisection, please just try to revert it and see if
that fixes your testcase.

You'll obviously need to revert the commit that removes
vmtruncate_range() too, since reverting 3f31d07571ee will re-introduce
the use of it (it's the next one:
17cf28afea2a1112f240a3a2da8af883be024811), but it looks like those two
commits revert cleanly and the end result seems to compile ok.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
