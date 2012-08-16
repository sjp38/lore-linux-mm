Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 997336B005D
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 11:07:23 -0400 (EDT)
Date: Thu, 16 Aug 2012 16:06:28 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 3/5] kmemleak: use rbtree instead of prio tree
Message-ID: <20120816150628.GE30876@arm.com>
References: <1344324343-3817-1-git-send-email-walken@google.com>
 <1344324343-3817-4-git-send-email-walken@google.com>
 <CANN689EOZ64V_AO8B6N0-_B0_HdQZVk3dH8Ce5c=m5Q=ySDKUg@mail.gmail.com>
 <20120809083127.GC14102@arm.com>
 <CAHkRjk4pQOktEGFZy9Jd5NDth8f_+JUC0OrgcRUaCFGUEUOTKg@mail.gmail.com>
 <CANN689F_FgFP0tUwpTJmhWO+XaLH9+2tEb6xYJzonXVv5KsOSA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANN689F_FgFP0tUwpTJmhWO+XaLH9+2tEb6xYJzonXVv5KsOSA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: "riel@redhat.com" <riel@redhat.com>, "peterz@infradead.org" <peterz@infradead.org>, "vrajesh@umich.edu" <vrajesh@umich.edu>, "daniel.santos@pobox.com" <daniel.santos@pobox.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>

On Wed, Aug 15, 2012 at 09:53:07PM +0100, Michel Lespinasse wrote:
> On Wed, Aug 15, 2012 at 9:36 AM, Catalin Marinas
> <catalin.marinas@arm.com> wrote:
> > Couldn't test it because the patch got messed up somewhere on the
> > email path (tabs replaced with spaces). Is there a Git tree I can grab
> > it from (or you could just send it to me separately as attachment)?
> 
> Sorry about that. The original patch I sent to lkml & linux-mm wasn't
> corrupted, but the forward I sent you after I realized I had forgotten
> to include you was.
> 
> https://lkml.org/lkml/2012/8/7/52 has the original patch, and "get
> diff 1" in the left column can be used to retrieve it.

Thanks. It works fine in my tests and the scanning time seems to have
got down from 22s to 19s on my board.

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
