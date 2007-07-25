Received: by py-out-1112.google.com with SMTP id f31so564461pyh
        for <linux-mm@kvack.org>; Wed, 25 Jul 2007 05:39:19 -0700 (PDT)
Message-ID: <5c77e14b0707250539q167a8922y22e26ac7a757c329@mail.gmail.com>
Date: Wed, 25 Jul 2007 14:39:19 +0200
From: "Jos Poortvliet" <jos@mijnkamer.nl>
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
In-Reply-To: <46A72EC9.4030706@yahoo.com.au>
MIME-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_Part_121633_10083849.1185367159136"
References: <46A57068.3070701@yahoo.com.au> <46A6D7D2.4050708@gmail.com>
	 <Pine.LNX.4.64.0707242211210.2229@asgard.lang.hm>
	 <46A6DFFD.9030202@gmail.com>
	 <30701.1185347660@turing-police.cc.vt.edu> <46A7074B.50608@gmail.com>
	 <20070725082822.GA13098@elte.hu> <46A70D37.3060005@gmail.com>
	 <5c77e14b0707250353r48458316x5e6adde6dbce1fbd@mail.gmail.com>
	 <46A72EC9.4030706@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Rene Herman <rene.herman@gmail.com>, Ingo Molnar <mingo@elte.hu>, david@lang.hm, Valdis.Kletnieks@vt.edu, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

------=_Part_121633_10083849.1185367159136
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Please ignore my mail... It was uninformed and not constructive. I should've
reread it and thought about it more. Sorry.

On 7/25/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>
> Jos Poortvliet wrote:
>
> > Nick
> > has been talking about 'fixing the updatedb thing' for years now, no
> patch
> > yet.
>
> Wrong Nick, I think.
>
> First I heard about the updatedb problem was a few months ago with people
> saying updatedb was causing their system to swap (that is, swap
> prefetching
> helped after updatedb). I haven't been able to even try to fix it because
> I
> can't reproduce it (I'm sitting on a machine with 256MB RAM), and nobody
> has wanted to help me.
>
>
> > Besides, he won't fix OO.o nor all other userspace stuff - so
> > actually,
> > he does NOT even promise an alternative. Not that I think fixing
> updatedb
> > would be cool, btw - it sure would, but it's no reason not to include
> swap
> > prefetch - it's mostly unrelated.
> >
> > I think everyone with >1 gb ram should stop saying 'I don't need it'
> > because
> > that's obvious for that hardware. Just like ppl having a dual- or
> quadcore
> > shouldn't even talk about scheduler interactivity stuff...
>
> Actually there are people with >1GB of ram who are saying it helps. Why do
> you want to shut people out of the discussion?
>
>
> > Desktop users want it, tests show it works, there is no alternative and
> the
> > maybe-promised-one won't even fix all cornercases. It's small, mostly
> > selfcontained. There is a maintainer. It's been stable for a long time.
> > It's
> > been in MM for a long time.
> >
> > Yet it doesn't make it. Andrew says 'some ppl have objections' (he means
> > Nick) and he doesn't see an advantage in it (at least 4 gig ram, right,
> > Andrew?).
> >
> > Do I miss things?
>
> You could try constructively contributing?
>
>
> > Apparently, it didn't get in yet - and I find it hard to believe Andrew
> > holds swapprefetch for reasons like the above. So it must be something
> > else.
> >
> >
> > Nick is saying tests have already proven swap prefetch to be helpfull,
> > that's not the problem. He calls the requirements to get in 'fuzzy'. OK.
>
> The test I have seen is the one that forces a huge amount of memory to
> swap out, waits, then touches it. That speeds up, and that's fine. That's
> a good sanity test to ensure it is working. Beyond that there are other
> considerations to getting something merged.
>
> --
> SUSE Labs, Novell Inc.
>

------=_Part_121633_10083849.1185367159136
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Please ignore my mail... It was uninformed and not constructive. I should&#39;ve reread it and thought about it more. Sorry.<br><br><div><span class="gmail_quote">On 7/25/07, <b class="gmail_sendername">Nick Piggin</b> &lt;
<a href="mailto:nickpiggin@yahoo.com.au">nickpiggin@yahoo.com.au</a>&gt; wrote:</span><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">Jos Poortvliet wrote:
<br><br>&gt; Nick<br>&gt; has been talking about &#39;fixing the updatedb thing&#39; for years now, no patch<br>&gt; yet.<br><br>Wrong Nick, I think.<br><br>First I heard about the updatedb problem was a few months ago with people
<br>saying updatedb was causing their system to swap (that is, swap prefetching<br>helped after updatedb). I haven&#39;t been able to even try to fix it because I<br>can&#39;t reproduce it (I&#39;m sitting on a machine with 256MB RAM), and nobody
<br>has wanted to help me.<br><br><br>&gt; Besides, he won&#39;t fix OO.o nor all other userspace stuff - so<br>&gt; actually,<br>&gt; he does NOT even promise an alternative. Not that I think fixing updatedb<br>&gt; would be cool, btw - it sure would, but it&#39;s no reason not to include swap
<br>&gt; prefetch - it&#39;s mostly unrelated.<br>&gt;<br>&gt; I think everyone with &gt;1 gb ram should stop saying &#39;I don&#39;t need it&#39;<br>&gt; because<br>&gt; that&#39;s obvious for that hardware. Just like ppl having a dual- or quadcore
<br>&gt; shouldn&#39;t even talk about scheduler interactivity stuff...<br><br>Actually there are people with &gt;1GB of ram who are saying it helps. Why do<br>you want to shut people out of the discussion?<br><br><br>&gt; Desktop users want it, tests show it works, there is no alternative and the
<br>&gt; maybe-promised-one won&#39;t even fix all cornercases. It&#39;s small, mostly<br>&gt; selfcontained. There is a maintainer. It&#39;s been stable for a long time.<br>&gt; It&#39;s<br>&gt; been in MM for a long time.
<br>&gt;<br>&gt; Yet it doesn&#39;t make it. Andrew says &#39;some ppl have objections&#39; (he means<br>&gt; Nick) and he doesn&#39;t see an advantage in it (at least 4 gig ram, right,<br>&gt; Andrew?).<br>&gt;<br>&gt; Do I miss things?
<br><br>You could try constructively contributing?<br><br><br>&gt; Apparently, it didn&#39;t get in yet - and I find it hard to believe Andrew<br>&gt; holds swapprefetch for reasons like the above. So it must be something
<br>&gt; else.<br>&gt;<br>&gt;<br>&gt; Nick is saying tests have already proven swap prefetch to be helpfull,<br>&gt; that&#39;s not the problem. He calls the requirements to get in &#39;fuzzy&#39;. OK.<br><br>The test I have seen is the one that forces a huge amount of memory to
<br>swap out, waits, then touches it. That speeds up, and that&#39;s fine. That&#39;s<br>a good sanity test to ensure it is working. Beyond that there are other<br>considerations to getting something merged.<br><br>--<br>
SUSE Labs, Novell Inc.<br></blockquote></div><br>

------=_Part_121633_10083849.1185367159136--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
