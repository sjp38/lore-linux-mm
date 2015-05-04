Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 69C296B0038
	for <linux-mm@kvack.org>; Mon,  4 May 2015 18:04:11 -0400 (EDT)
Received: by labbd9 with SMTP id bd9so114361656lab.2
        for <linux-mm@kvack.org>; Mon, 04 May 2015 15:04:10 -0700 (PDT)
Received: from v094114.home.net.pl (v094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id od5si10933561lbb.123.2015.05.04.15.04.09
        for <linux-mm@kvack.org>;
        Mon, 04 May 2015 15:04:09 -0700 (PDT)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH v2 3/4] PM / Hibernate: fix SANITIZE_FREED_PAGES
Date: Tue, 05 May 2015 00:29:10 +0200
Message-ID: <28072506.ijDyy3q5rs@vostro.rjw.lan>
In-Reply-To: <5547E995.9980.80084D6@pageexec.freemail.hu>
References: <1430774218-5311-1-git-send-email-anisse@astier.eu> <1430774218-5311-4-git-send-email-anisse@astier.eu> <5547E995.9980.80084D6@pageexec.freemail.hu>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pageexec@freemail.hu
Cc: Anisse Astier <anisse@astier.eu>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pavel Machek <pavel@ucw.cz>, Linux PM list <linux-pm@vger.kernel.org>

On Monday, May 04, 2015 11:50:13 PM PaX Team wrote:
> On 4 May 2015 at 23:16, Anisse Astier wrote:
> 
> > SANITIZE_FREED_PAGES feature relies on having all pages going through
> > the free_pages_prepare path in order to be cleared before being used. In
> > the hibernate use case, pages will automagically appear in the system
> > without being cleared.
> 
> is this based on debugging/code reading/discussions with hibernation folks
> (i see none of them on CC, added them now) or is it just a brute force attempt
> to fix the symptoms? if the former, it'd be nice to share some more details
> and have Acks from the code owners.

I haven't seen it, for one, and I'm wondering why the "clearing" cannot be done
at the swsusp_free() time?

In any case, please CC hibernation-related patches and discussions thereof to
linux-pm@vger.kernel.org.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
