Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 0FFF76B0074
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 23:23:59 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id uo1so678787pbc.31
        for <linux-mm@kvack.org>; Tue, 08 Jan 2013 20:23:59 -0800 (PST)
Date: Tue, 8 Jan 2013 20:23:46 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: oops in copy_page_rep()
In-Reply-To: <20130108173747.GF9163@redhat.com>
Message-ID: <alpine.LNX.2.00.1301082020280.2351@eggly.anvils>
References: <20130105152208.GA3386@redhat.com> <CAJd=RBCb0oheRnVCM4okVKFvKGzuLp9GpZJCkVY3RR-J=XEoBA@mail.gmail.com> <alpine.LNX.2.00.1301061037140.28950@eggly.anvils> <CAJd=RBAps4Qk9WLYbQhLkJd8d12NLV0CbjPYC6uqH_-L+Vu0VQ@mail.gmail.com>
 <CA+55aFyYAf6ztDLsxWFD+6jb++y0YNjso-9j+83Mm+3uQ=8PdA@mail.gmail.com> <CAJd=RBDTvCcYV8qAd-++_DOyDSypQD4Dvt216pG9nTQnWA2uCA@mail.gmail.com> <CA+55aFzfUABPycR82aNQhHNasQkL1kmxLN1rD0DJcByFtead3g@mail.gmail.com> <20130108163141.GA27555@shutemov.name>
 <CA+55aFzaTvF7nYxWBT-G_b=xGz+_akRAeJ=U9iHy+Y=ZPo=pbA@mail.gmail.com> <20130108173747.GF9163@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>

On Tue, 8 Jan 2013, Andrea Arcangeli wrote:
> 
> Looking at this, one thing that isn't clear is where the page_count is
> checked in migrate_misplaced_transhuge_page. Ok that it's unable to
> migrate anon transhuge COW shared pages so it doesn't need to mess
> with rmap (the mapcount check makes it safe), but it shouldn't be
> allowed to migrate memory that has gup direct-IO in flight (and that
> can only be detected with a page_count vs mapcount check). Real
> migrate does page_freeze_refs to be safe. Mel comments?

Yes, I protested to Mel about that before the holidays, and he
quickly provided a patch, now in akpm's tree; but checking it again
today, I believe it's still not quite right yet - see other mail.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
