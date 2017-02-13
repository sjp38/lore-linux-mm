Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F406F6B0038
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 05:05:33 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id h7so41136910wjy.6
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 02:05:33 -0800 (PST)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id 196si4910990wmg.65.2017.02.13.02.05.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Feb 2017 02:05:32 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 2696C1C174A
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 10:05:32 +0000 (GMT)
Date: Mon, 13 Feb 2017 10:05:31 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: PCID review?
Message-ID: <20170213100531.giv4rlihqid6ocz4@techsingularity.net>
References: <CALCETrVSiS22KLvYxZarexFHa3C7Z-ys_Lt2WV_63b4-tuRpQA@mail.gmail.com>
 <CALCETrVfah6AFG5mZDjVcRrdXKL=07+WC9ES9ZKU90XqVpWCOg@mail.gmail.com>
 <20170209001042.ahxmoqegr6h74mle@techsingularity.net>
 <CALCETrUiUnZ1AWHjx8-__t0DUwryys9O95GABhhpG9AnHwrg9Q@mail.gmail.com>
 <20170210110157.dlejz7szrj3r3pwq@techsingularity.net>
 <CALCETrVjhVqpHTpQ--AVDpWQAb44b265sesou50wSec4rs9sRw@mail.gmail.com>
 <20170210215708.j54cawm23nepgimd@techsingularity.net>
 <CALCETrWToSZZsXHyrXg+YRiyvjRtWd7J0Myvn_mjJJdJoCXr+w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CALCETrWToSZZsXHyrXg+YRiyvjRtWd7J0Myvn_mjJJdJoCXr+w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Borislav Petkov <bp@alien8.de>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Fri, Feb 10, 2017 at 02:07:19PM -0800, Andy Lutomirski wrote:
> > Ok, probably for the best albeit that is based on an inability to figure
> > out how it could be done efficiently and a suspicion that if it could be
> > done, the scheduler would be doing it already.
> >
> 
> FWIW, I am doing a bit of this.  For remote CPUs that aren't currently
> running a given mm, I just bump a per-mm generation count so that they
> know to flush next time around in switch_mm().  I'll need to add a new
> hook to the batched flush code to get this right, and I'll cc you on
> that.  Stay tuned.
> 

Ok, thanks.

> > [1] I could be completely wrong, I'm basing this on how people have
> >     behaved in the past during TLB-flush related discussions. They
> >     might have changed their mind.
> 
> We'll see.  The main benchmark that I'm relying on (so far) is that
> context switches get way faster, just ping ponging back and forth.  I
> suspect that the TLB refill cost is only a small part.
> 

Note that such a benchmark is not going to measure the TLB flush cost.
In itself, this is not bad but I suspect that the applications that care
about interference from TLB flushes by unrelated processes are not
applications that are context-switch intensive.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
