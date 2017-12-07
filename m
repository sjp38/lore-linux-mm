Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 25C886B0069
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 14:57:38 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id j3so6474556pfh.16
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 11:57:38 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f23si989424pgv.509.2017.12.07.11.57.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 11:57:37 -0800 (PST)
Date: Thu, 7 Dec 2017 11:57:27 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 0/2] mm: introduce MAP_FIXED_SAFE
Message-ID: <20171207195727.GA26792@bombadil.infradead.org>
References: <20171129144219.22867-1-mhocko@kernel.org>
 <CAGXu5jLa=b2HhjWXXTQunaZuz11qUhm5aNXHpS26jVqb=G-gfw@mail.gmail.com>
 <20171130065835.dbw4ajh5q5whikhf@dhcp22.suse.cz>
 <20171201152640.GA3765@rei>
 <87wp20e9wf.fsf@concordia.ellerman.id.au>
 <20171206045433.GQ26021@bombadil.infradead.org>
 <20171206070355.GA32044@bombadil.infradead.org>
 <87bmjbks4c.fsf@concordia.ellerman.id.au>
 <CAGXu5jLWRQn6EaXEEvdvXr+4gbiJawwp1EaLMfYisHVfMiqgSA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jLWRQn6EaXEEvdvXr+4gbiJawwp1EaLMfYisHVfMiqgSA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Cyril Hrubis <chrubis@suse.cz>, Michal Hocko <mhocko@kernel.org>, Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>, Pavel Machek <pavel@ucw.cz>

On Thu, Dec 07, 2017 at 11:14:27AM -0800, Kees Cook wrote:
> On Wed, Dec 6, 2017 at 9:46 PM, Michael Ellerman <mpe@ellerman.id.au> wrote:
> > Matthew Wilcox <willy@infradead.org> writes:
> >> So, just like we currently say "exactly one of MAP_SHARED or MAP_PRIVATE",
> >> we could add a new paragraph saying "at most one of MAP_FIXED or
> >> MAP_REQUIRED" and "any of the following values".
> >
> > MAP_REQUIRED doesn't immediately grab me, but I don't actively dislike
> > it either :)
> >
> > What about MAP_AT_ADDR ?
> >
> > It's short, and says what it does on the tin. The first argument to mmap
> > is actually called "addr" too.
> 
> "FIXED" is supposed to do this too.
> 
> Pavel suggested:
> 
> MAP_ADD_FIXED
> 
> (which is different from "use fixed", and describes why it would fail:
> can't add since it already exists.)
> 
> Perhaps "MAP_FIXED_NEW"?
> 
> There has been a request to drop "FIXED" from the name, so these:
> 
> MAP_FIXED_NOCLOBBER
> MAP_FIXED_NOREPLACE
> MAP_FIXED_ADD
> MAP_FIXED_NEW
> 
> Could be:
> 
> MAP_NOCLOBBER
> MAP_NOREPLACE
> MAP_ADD
> MAP_NEW
> 
> and we still have the unloved, but acceptable:
> 
> MAP_REQUIRED
> 
> My vote is still for "NOREPLACE" or "NOCLOBBER" since it's very
> specific, though "NEW" is pretty clear too.

How about MAP_NOFORCE?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
