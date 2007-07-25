Received: by py-out-1112.google.com with SMTP id f31so491243pyh
        for <linux-mm@kvack.org>; Wed, 25 Jul 2007 03:53:06 -0700 (PDT)
Message-ID: <5c77e14b0707250353r48458316x5e6adde6dbce1fbd@mail.gmail.com>
Date: Wed, 25 Jul 2007 12:53:05 +0200
From: "Jos Poortvliet" <jos@mijnkamer.nl>
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
In-Reply-To: <46A70D37.3060005@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_Part_120973_28657361.1185360785793"
References: <46A57068.3070701@yahoo.com.au>
	 <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
	 <46A6CC56.6040307@yahoo.com.au> <46A6D7D2.4050708@gmail.com>
	 <Pine.LNX.4.64.0707242211210.2229@asgard.lang.hm>
	 <46A6DFFD.9030202@gmail.com>
	 <30701.1185347660@turing-police.cc.vt.edu> <46A7074B.50608@gmail.com>
	 <20070725082822.GA13098@elte.hu> <46A70D37.3060005@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@gmail.com>
Cc: Ingo Molnar <mingo@elte.hu>, david@lang.hm, Nick Piggin <nickpiggin@yahoo.com.au>, Valdis.Kletnieks@vt.edu, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

------=_Part_120973_28657361.1185360785793
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 7/25/07, Rene Herman <rene.herman@gmail.com> wrote:
>
> On 07/25/2007 10:28 AM, Ingo Molnar wrote:
>
> >> Regardless, I'll stand by "[by disabling updatedb] the problem will
> >> for a large part be solved" as I expect approximately 94.372 percent
> >> of Linux desktop users couldn't care less about locate.
> >
> > i think that approach is illogical: because Linux mis-handled a mixed
> > workload the answer is to ... remove a portion of that workload?
>
> No. It got snipped but I introduced the comment by saying it was a "that's
> not the point" kind of thing. Sometimes things that aren't the point are
> still true though and in the case of Linux desktop users complaining about
> updatedb runs, a comment that says that for many an obvious solution would
> be to stop running the damned thing is not in any sense illogical.
>
> Also note I'm not against swap prefetch or anything. I don't use it and do
> not believe I have a pressing need for it, but do suspect it has potential
> to make quite a bit of difference on some things -- if only to drastically
> reduce seeks if it means it's swapping in larger chunks than a randomly
> faulting program would.


I wonder what your hardware is. Con talked about the diff in hardware
between most endusers and the kernel developers. Yes, swap prefetch doesn't
help if you have 3 GB ram, but it DOES do a lot on a 256 mb laptop... After
using OO.o, the system continues to be slow for a long time. With swap
prefetch, it's back up speed much faster. Con has showed a benchmark for
this with speedups of 10 times and more, users mentioned they liked it. Nick
has been talking about 'fixing the updatedb thing' for years now, no patch
yet. Besides, he won't fix OO.o nor all other userspace stuff - so actually,
he does NOT even promise an alternative. Not that I think fixing updatedb
would be cool, btw - it sure would, but it's no reason not to include swap
prefetch - it's mostly unrelated.

I think everyone with >1 gb ram should stop saying 'I don't need it' because
that's obvious for that hardware. Just like ppl having a dual- or quadcore
shouldn't even talk about scheduler interactivity stuff...

Desktop users want it, tests show it works, there is no alternative and the
maybe-promised-one won't even fix all cornercases. It's small, mostly
selfcontained. There is a maintainer. It's been stable for a long time. It's
been in MM for a long time.

Yet it doesn't make it. Andrew says 'some ppl have objections' (he means
Nick) and he doesn't see an advantage in it (at least 4 gig ram, right,
Andrew?).

Do I miss things?

Apparently, it didn't get in yet - and I find it hard to believe Andrew
holds swapprefetch for reasons like the above. So it must be something else.


Nick is saying tests have already proven swap prefetch to be helpfull,
that's not the problem. He calls the requirements to get in 'fuzzy'. OK.
Beer is fuzzy, do we need to offer beer to someone? If Andrew promises to
come to FOSDEM again next year, I'll offer him a beer, if that helps...
Anything else? A nice massage?


Rene.
> _______________________________________________
> http://ck.kolivas.org/faqs/replying-to-mailing-list.txt
> ck mailing list - mailto: ck@vds.kolivas.org
> http://vds.kolivas.org/mailman/listinfo/ck
>

------=_Part_120973_28657361.1185360785793
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 7/25/07, <b class="gmail_sendername">Rene Herman</b> &lt;<a href="mailto:rene.herman@gmail.com">rene.herman@gmail.com</a>&gt; wrote:<div><span class="gmail_quote"></span><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
On 07/25/2007 10:28 AM, Ingo Molnar wrote:<br><br>&gt;&gt; Regardless, I&#39;ll stand by &quot;[by disabling updatedb] the problem will<br>&gt;&gt; for a large part be solved&quot; as I expect approximately 94.372 percent
<br>&gt;&gt; of Linux desktop users couldn&#39;t care less about locate.<br>&gt;<br>&gt; i think that approach is illogical: because Linux mis-handled a mixed<br>&gt; workload the answer is to ... remove a portion of that workload?
<br><br>No. It got snipped but I introduced the comment by saying it was a &quot;that&#39;s<br>not the point&quot; kind of thing. Sometimes things that aren&#39;t the point are<br>still true though and in the case of Linux desktop users complaining about
<br>updatedb runs, a comment that says that for many an obvious solution would<br>be to stop running the damned thing is not in any sense illogical.<br><br>Also note I&#39;m not against swap prefetch or anything. I don&#39;t use it and do
<br>not believe I have a pressing need for it, but do suspect it has potential<br>to make quite a bit of difference on some things -- if only to drastically<br>reduce seeks if it means it&#39;s swapping in larger chunks than a randomly
<br>faulting program would.</blockquote><div><br>I wonder what your hardware is. Con talked about the diff in hardware between most endusers and the kernel developers. Yes, swap prefetch doesn&#39;t help if you have 3 GB ram, but it DOES do a lot on a 256 mb laptop... After using 
OO.o, the system continues to be slow for a long time. With swap prefetch, it&#39;s back up speed much faster. Con has showed a benchmark for this with speedups of 10 times and more, users mentioned they liked it. Nick has been talking about &#39;fixing the updatedb thing&#39; for years now, no patch yet. Besides, he won&#39;t fix 
OO.o nor all other userspace stuff - so actually, he does NOT even promise an alternative. Not that I think fixing updatedb would be cool, btw - it sure would, but it&#39;s no reason not to include swap prefetch - it&#39;s mostly unrelated.
<br><br>I think everyone with &gt;1 gb ram should stop saying &#39;I don&#39;t need it&#39; because that&#39;s obvious for that hardware. Just like ppl having a dual- or quadcore shouldn&#39;t even talk about scheduler interactivity stuff...
<br><br>Desktop users want it, tests show it works, there is no alternative and the maybe-promised-one won&#39;t even fix all cornercases. It&#39;s small, mostly selfcontained. There is a maintainer. It&#39;s been stable for a long time. It&#39;s been in MM for a long time.
<br><br>Yet it doesn&#39;t make it. Andrew says &#39;some ppl have objections&#39; (he means Nick) and he doesn&#39;t see an advantage in it (at least 4 gig ram, right, Andrew?).<br></div><br>Do I miss things?<br><br>Apparently, it didn&#39;t get in yet - and I find it hard to believe Andrew holds swapprefetch for reasons like the above. So it must be something else. 
<br><br>Nick is saying tests have already proven swap prefetch to be helpfull, that&#39;s not the problem. He calls the requirements to get in &#39;fuzzy&#39;. OK. Beer is fuzzy, do we need to offer beer to someone? If Andrew promises to come to FOSDEM again next year, I&#39;ll offer him a beer, if that helps... Anything else? A nice massage?
<br><br><br><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">Rene.<br>_______________________________________________<br><a href="http://ck.kolivas.org/faqs/replying-to-mailing-list.txt">
http://ck.kolivas.org/faqs/replying-to-mailing-list.txt</a><br>ck mailing list - mailto: <a href="mailto:ck@vds.kolivas.org">ck@vds.kolivas.org</a><br><a href="http://vds.kolivas.org/mailman/listinfo/ck">http://vds.kolivas.org/mailman/listinfo/ck
</a><br></blockquote></div><br>

------=_Part_120973_28657361.1185360785793--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
