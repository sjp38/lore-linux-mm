From: "Jos Poortvliet" <jos@mijnkamer.nl>
Subject: Re: Re: howto get a patch merged (WAS: Re: -mm merge plans for
	2.6.23)
Date: Thu, 26 Jul 2007 15:54:40 +0200
Message-ID: <5c77e14b0707260654n508b6c13tce656917a7b532ae@mail.gmail.com>
References: <367a23780707250830i20a04a60n690e8da5630d39a9@mail.gmail.com>
	<46A773EA.5030103@gmail.com>
	<a491f91d0707251015x75404d9fld7b3382f69112028@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============030156646982893109=="
Return-path: <ck-bounces@vds.kolivas.org>
In-Reply-To: <a491f91d0707251015x75404d9fld7b3382f69112028@mail.gmail.com>
List-Unsubscribe: <http://bhhdoa.org.au/mailman/listinfo/ck>,
	<mailto:ck-request@vds.kolivas.org?subject=unsubscribe>
List-Archive: <http://bhhdoa.org.au/pipermail/ck>
List-Post: <mailto:ck@vds.kolivas.org>
List-Help: <mailto:ck-request@vds.kolivas.org?subject=help>
List-Subscribe: <http://bhhdoa.org.au/mailman/listinfo/ck>,
	<mailto:ck-request@vds.kolivas.org?subject=subscribe>
Sender: ck-bounces@vds.kolivas.org
Errors-To: ck-bounces@vds.kolivas.org
To: Robert Deaton <false.hopes@gmail.com>
Cc: ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rene Herman <rene.herman@gmail.com>
List-Id: linux-mm.kvack.org

--===============030156646982893109==
Content-Type: multipart/alternative;
	boundary="----=_Part_133262_12784483.1185458080050"

------=_Part_133262_12784483.1185458080050
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 7/25/07, Robert Deaton <false.hopes@gmail.com> wrote:
>
> On 7/25/07, Rene Herman <rene.herman@gmail.com> wrote:
> > And there we go again -- off into blabber-land. Why does swap-prefetch
> help
> > updatedb? Or doesn't it? And if it doesn't, why should anyone trust
> anything
> > else someone who said it does says?
>
> I don't think anyone has ever argued that swap-prefetch directly helps
> the performance of updatedb in any way, however, I do recall people
> mentioning that updatedb, being a ram intensive task, will often cause
> things to be swapped out while it runs on say a nightly cronjob. If a
> person is not at their computer, updatedb will run, cause all their
> applications to be swapped out, finish its work, and exit, leaving all
> the other applications that would have otherwise been left in RAM for
> when the user returns to his/her computer in swap. Thus, when someone
> returns, you have to wait for all your applications to be swapped back
> in.
>
> Swap prefetch, on the other hand, would have kicked in shortly after
> updatedb finished, leaving the applications in swap for a speedy
> recovery when the person comes back to their computer.


Note that the updatedb scenario should actually be properly fixed some other
way: updatedb, touching everything only once, shouldn't dirty the caches
like it does.

But the same thing happens when you open a 10 megapixel picture for editing
in Krita, or start OpenOffice. After closing them, a lot of ram is freed.
Yet the data which is pushed to swap when you used these apps will remain
there, until you start using them. Swap-prefetch will gently get this data
back (while keeping it also in swap, to ensure a quick response when the ram
is needed for another big app - so you have the advantages, but not the
disadvantages!).

I haven't heard anyone claim this scenario can be 'fixed' in a 'more proper'
way than with swap prefetch. And nobody has been able to prove that
swap-prefetch has any bad sideeffects. So it IS a net-gain. But only for
desktop users who hit swap. So it's good for those doing video and photo
editing, for example. Or low-mem systems with OpenOffice. Or ppl doing heavy
compiles while low on ram.

It doesn't help nor hinder laptop users (it is automatically turned off on
laptops to save power), and it doesn't help nor hinder big 16-gb-ram systems
(they probably don't hit swap often, quick responses might not be important,
they're mostly busy so swap-prefetch doesn't run and most importantly: they
won't have it turned on anyway).

--
> --Robert Deaton
> _______________________________________________
> http://ck.kolivas.org/faqs/replying-to-mailing-list.txt
> ck mailing list - mailto: ck@vds.kolivas.org
> http://vds.kolivas.org/mailman/listinfo/ck
>

------=_Part_133262_12784483.1185458080050
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 7/25/07, <b class="gmail_sendername">Robert Deaton</b> &lt;<a href="mailto:false.hopes@gmail.com">false.hopes@gmail.com</a>&gt; wrote:<div><span class="gmail_quote"></span><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
On 7/25/07, Rene Herman &lt;<a href="mailto:rene.herman@gmail.com">rene.herman@gmail.com</a>&gt; wrote:<br>&gt; And there we go again -- off into blabber-land. Why does swap-prefetch help<br>&gt; updatedb? Or doesn&#39;t it? And if it doesn&#39;t, why should anyone trust anything
<br>&gt; else someone who said it does says?<br><br>I don&#39;t think anyone has ever argued that swap-prefetch directly helps<br>the performance of updatedb in any way, however, I do recall people<br>mentioning that updatedb, being a ram intensive task, will often cause
<br>things to be swapped out while it runs on say a nightly cronjob. If a<br>person is not at their computer, updatedb will run, cause all their<br>applications to be swapped out, finish its work, and exit, leaving all<br>
the other applications that would have otherwise been left in RAM for<br>when the user returns to his/her computer in swap. Thus, when someone<br>returns, you have to wait for all your applications to be swapped back<br>in.
<br><br>Swap prefetch, on the other hand, would have kicked in shortly after<br>updatedb finished, leaving the applications in swap for a speedy<br>recovery when the person comes back to their computer.</blockquote><div><br>
Note that the updatedb scenario should actually be properly fixed some other way: updatedb, touching everything only once, shouldn&#39;t dirty the caches like it does.<br><br>But the same thing happens when you open a 10 megapixel picture for editing in Krita, or start OpenOffice. After closing them, a lot of ram is freed. Yet the data which is pushed to swap when you used these apps will remain there, until you start using them. Swap-prefetch will gently get this data back (while keeping it also in swap, to ensure a quick response when the ram is needed for another big app - so you have the advantages, but not the disadvantages!).
<br><br>I haven&#39;t heard anyone claim this scenario can be &#39;fixed&#39; in a &#39;more proper&#39; way than with swap prefetch. And nobody has been able to prove that swap-prefetch has any bad sideeffects. So it IS a net-gain. But only for desktop users who hit swap. So it&#39;s good for those doing video and photo editing, for example. Or low-mem systems with OpenOffice. Or ppl doing heavy compiles while low on ram.
<br><br>It doesn&#39;t help nor hinder laptop users (it is automatically turned off on laptops to save power), and it doesn&#39;t help nor hinder big 16-gb-ram systems (they probably don&#39;t hit swap often, quick responses might not be important, they&#39;re mostly busy so swap-prefetch doesn&#39;t run and most importantly: they won&#39;t have it turned on anyway).
<br></div><br><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">--<br>--Robert Deaton<br>_______________________________________________<br><a href="http://ck.kolivas.org/faqs/replying-to-mailing-list.txt">
http://ck.kolivas.org/faqs/replying-to-mailing-list.txt</a><br>ck mailing list - mailto: <a href="mailto:ck@vds.kolivas.org">ck@vds.kolivas.org</a><br><a href="http://vds.kolivas.org/mailman/listinfo/ck">http://vds.kolivas.org/mailman/listinfo/ck
</a><br></blockquote></div><br>

------=_Part_133262_12784483.1185458080050--

--===============030156646982893109==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============030156646982893109==--
