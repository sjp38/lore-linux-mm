Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 80B906B005D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 16:53:09 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so2750408ghr.14
        for <linux-mm@kvack.org>; Wed, 15 Aug 2012 13:53:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHkRjk4pQOktEGFZy9Jd5NDth8f_+JUC0OrgcRUaCFGUEUOTKg@mail.gmail.com>
References: <1344324343-3817-1-git-send-email-walken@google.com>
	<1344324343-3817-4-git-send-email-walken@google.com>
	<CANN689EOZ64V_AO8B6N0-_B0_HdQZVk3dH8Ce5c=m5Q=ySDKUg@mail.gmail.com>
	<20120809083127.GC14102@arm.com>
	<CAHkRjk4pQOktEGFZy9Jd5NDth8f_+JUC0OrgcRUaCFGUEUOTKg@mail.gmail.com>
Date: Wed, 15 Aug 2012 13:53:07 -0700
Message-ID: <CANN689F_FgFP0tUwpTJmhWO+XaLH9+2tEb6xYJzonXVv5KsOSA@mail.gmail.com>
Subject: Re: [PATCH 3/5] kmemleak: use rbtree instead of prio tree
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "riel@redhat.com" <riel@redhat.com>, "peterz@infradead.org" <peterz@infradead.org>, "vrajesh@umich.edu" <vrajesh@umich.edu>, "daniel.santos@pobox.com" <daniel.santos@pobox.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>

On Wed, Aug 15, 2012 at 9:36 AM, Catalin Marinas
<catalin.marinas@arm.com> wrote:
> Couldn't test it because the patch got messed up somewhere on the
> email path (tabs replaced with spaces). Is there a Git tree I can grab
> it from (or you could just send it to me separately as attachment)?

Sorry about that. The original patch I sent to lkml & linux-mm wasn't
corrupted, but the forward I sent you after I realized I had forgotten
to include you was.

https://lkml.org/lkml/2012/8/7/52 has the original patch, and "get
diff 1" in the left column can be used to retrieve it.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
