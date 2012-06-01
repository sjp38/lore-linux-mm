Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 0178E6B004D
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 12:39:20 -0400 (EDT)
Date: Fri, 1 Jun 2012 18:39:18 +0200
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: WARNING: at mm/page-writeback.c:1990
 __set_page_dirty_nobuffers+0x13a/0x170()
Message-ID: <20120601163918.GB329@x4>
References: <20120530163317.GA13189@redhat.com>
 <20120531005739.GA4532@redhat.com>
 <20120601023107.GA19445@redhat.com>
 <alpine.LSU.2.00.1206010030050.8462@eggly.anvils>
 <20120601161640.GA329@x4>
 <CA+55aFyrX30_=V=fiOAt8rXOuj=YdbgrzehknSz9-6qNGKFp-Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyrX30_=V=fiOAt8rXOuj=YdbgrzehknSz9-6qNGKFp-Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2012.06.01 at 09:28 -0700, Linus Torvalds wrote:
> On Fri, Jun 1, 2012 at 9:16 AM, Markus Trippelsdorf
> <markus@trippelsdorf.de> wrote:
> >
> > I've also hit this warning today:
> 
> Can you try the patch by Hugh Dickins earlier in this thread?

I will try. But please notice that the warning just happened per
accident. I don't know how to reproduce the issue yet.

> Dave is reporting tentative success with it, even though I don't think
> we really understand this thing fully yet. Getting way more testing
> would still be good, though.

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
