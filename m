Received: by nz-out-0506.google.com with SMTP id s1so26365nze
        for <linux-mm@kvack.org>; Tue, 24 Jul 2007 17:59:24 -0700 (PDT)
Message-ID: <b21f8390707241759j7fe9e5eai7e47bb56e4a1b376@mail.gmail.com>
Date: Wed, 25 Jul 2007 10:59:23 +1000
From: "Matthew Hawkins" <darthmdh@gmail.com>
Subject: Re: [ck] Re: -mm merge plans for 2.6.23 - Completely Fair Swap Prefetch
In-Reply-To: <f858c6$2k3$1@sea.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	 <200707102015.44004.kernel@kolivas.org>
	 <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	 <46A57068.3070701@yahoo.com.au>
	 <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
	 <46A58B49.3050508@yahoo.com.au> <f858c6$2k3$1@sea.gmane.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Frank Kingswood <frank@kingswood-consulting.co.uk>
Cc: ck@vds.kolivas.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/25/07, Frank Kingswood <frank@kingswood-consulting.co.uk> wrote:
> Nick Piggin wrote:
>
> > However, if we can improve basic page reclaim where it is obviously
> > lacking, that is always preferable. eg: being a highly speculative
> > operation, swap prefetch is not great for power efficiency -- but we
> > still want laptop users to have a good experience as well, right?
>
> Maybe we need someone (say, a Redhat engineer) to develop a "Completely
> Fair Swap Prefetch"?

swap prefetch is disabled by default on laptops.

What I like about swap prefetch is that, being completely runtime
selectable, it leaves it up to the sysadmin whether they want it or
not.  A distribution can ask a question at install time (or, better
still, since most distributions currently have separate server and
desktop installs, just do the appropriate thing depending on what is
being installed) and the sysadmin is free to alter that choice any
time in the future.  They can even set up a cron job to alter it for
them at multiple times in the future ;-)

-- 
Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
