Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 73E036B033D
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 23:54:44 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id v25so2037604pfg.14
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 20:54:44 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id s10si1354813pfg.229.2017.12.05.20.54.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 20:54:43 -0800 (PST)
Date: Tue, 5 Dec 2017 20:54:35 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 0/2] mm: introduce MAP_FIXED_SAFE
Message-ID: <20171206045433.GQ26021@bombadil.infradead.org>
References: <20171129144219.22867-1-mhocko@kernel.org>
 <CAGXu5jLa=b2HhjWXXTQunaZuz11qUhm5aNXHpS26jVqb=G-gfw@mail.gmail.com>
 <20171130065835.dbw4ajh5q5whikhf@dhcp22.suse.cz>
 <20171201152640.GA3765@rei>
 <87wp20e9wf.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87wp20e9wf.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Cyril Hrubis <chrubis@suse.cz>, Michal Hocko <mhocko@kernel.org>, Kees Cook <keescook@chromium.org>, Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>

On Wed, Dec 06, 2017 at 03:51:44PM +1100, Michael Ellerman wrote:
> Cyril Hrubis <chrubis@suse.cz> writes:
> 
> > Hi!
> >> > MAP_FIXED_UNIQUE
> >> > MAP_FIXED_ONCE
> >> > MAP_FIXED_FRESH
> >> 
> >> Well, I can open a poll for the best name, but none of those you are
> >> proposing sound much better to me. Yeah, naming sucks...
> >
> > Given that MAP_FIXED replaces the previous mapping MAP_FIXED_NOREPLACE
> > would probably be a best fit.
> 
> Yeah that could work.
> 
> I prefer "no clobber" as I just suggested, because the existing
> MAP_FIXED doesn't politely "replace" a mapping, it destroys the current
> one - which you or another thread may be using - and clobbers it with
> the new one.

It's longer than MAP_FIXED_WEAK :-P

You'd have to be pretty darn strong to clobber an existing mapping.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
