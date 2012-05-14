Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 635AA6B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 18:52:57 -0400 (EDT)
Received: by ggm4 with SMTP id 4so3633348ggm.14
        for <linux-mm@kvack.org>; Mon, 14 May 2012 15:52:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1205140940550.26304@router.home>
References: <4FAC9786.9060200@kernel.org> <20120511131404.GQ11435@suse.de>
 <4FADA007.3020309@gmail.com> <20120514133210.GE29102@suse.de>
 <1337003515.2443.35.camel@twins> <alpine.DEB.2.00.1205140857380.26304@router.home>
 <1337004860.2443.47.camel@twins> <alpine.DEB.2.00.1205140940550.26304@router.home>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Mon, 14 May 2012 18:52:36 -0400
Message-ID: <CAHGf_=q=MsmsXtQfWSoyfCpveRaX9-Ns11t9vXQjjt9WHZK5Og@mail.gmail.com>
Subject: Re: Allow migration of mlocked page?
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, Theodore Ts'o <tytso@mit.edu>, roland@kernel.org

On Mon, May 14, 2012 at 10:43 AM, Christoph Lameter <cl@linux.com> wrote:
> On Mon, 14 May 2012, Peter Zijlstra wrote:
>
>> > A PG_pinned could allow us to make that distinction to avoid overhead in
>> > the reclaim and page migration logic and also we could add some semantics
>> > that avoid page faults.
>>
>> Either that or a VMA flag, I think both infiniband and whatever new
>> mlock API we invent will pretty much always be VMA wide. Or does the
>> infinimuck take random pages out? All I really know about IB is to stay
>> the #$%! away from it [as Mel recently learned the hard way] :-)
>
> Devices (also infiniband) register buffers allocated on the heap and
> increase the page count of the pages. Its not VMA bound.
>
> Creating a VMA flag would force device driver writers to break up VMAs I
> think.

Why do you dislike vma splitting so much? Infiniband is usually HPC
(i.e. 64bit arch)
and number of VMAs are not big matter. Usually IB register buffer is
not one or two pages. It's usually bigger.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
