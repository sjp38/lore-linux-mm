Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2476B0031
	for <linux-mm@kvack.org>; Sun, 12 Jan 2014 08:56:10 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id hm2so1240339wib.10
        for <linux-mm@kvack.org>; Sun, 12 Jan 2014 05:56:09 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id dt8si5511066wib.9.2014.01.12.05.56.08
        for <linux-mm@kvack.org>;
        Sun, 12 Jan 2014 05:56:09 -0800 (PST)
Date: Sun, 12 Jan 2014 14:56:00 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC PATCH] mm: thp: Add per-mm_struct flag to control THP
Message-ID: <20140112135600.GA15051@redhat.com>
References: <1389383718-46031-1-git-send-email-athorlton@sgi.com> <20140111155337.GA16003@redhat.com> <20140111193003.GA10649@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140111193003.GA10649@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andy Lutomirski <luto@amacapital.net>, Al Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org

On 01/11, Alex Thorlton wrote:
>
> On Sat, Jan 11, 2014 at 04:53:37PM +0100, Oleg Nesterov wrote:
>
> > I simply can't understand, this all looks like overkill. Can't you simply add
> >
> > 	#idfef CONFIG_TRANSPARENT_HUGEPAGE
> > 	case GET:
> > 		error = test_bit(MMF_THP_DISABLE);
> > 		break;
> > 	case PUT:
> > 		if (arg2)
> > 			set_bit();
> > 		else
> > 			clear_bit();
> > 		break;
> > 	#endif
> >
> > into sys_prctl() ?	
>
> That's probably a better solution.  I wasn't sure whether or not it was
> better to have two functions to handle this, or to have one function
> handle both.  If you think it's better to just handle both with one,
> that's easy enough to change.

Personally I think sys_prctl() can handle this itself, without a helper.
But of course I won't argue, this is up to you.

My only point is, the kernel is already huge ;) Imho it makes sense to
try to lessen the code size, when the logic is simple.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
