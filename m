Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7E5BF8D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 20:55:38 -0500 (EST)
Received: by iyf13 with SMTP id 13so1987887iyf.14
        for <linux-mm@kvack.org>; Thu, 03 Mar 2011 17:55:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110303104430.B93F.A69D9226@jp.fujitsu.com>
References: <AANLkTik7MA6YcrWVbjFhQsN0arR72xmH9g1M2Yi-E_B-@mail.gmail.com>
	<20110303104430.B93F.A69D9226@jp.fujitsu.com>
Date: Fri, 4 Mar 2011 09:55:36 +0800
Message-ID: <AANLkTine1S9bjnqUCsYRhenYH6TUJTdOOQvdQ1nKY8Wv@mail.gmail.com>
Subject: Re: [RFC PATCH 0/5] Add accountings for Page Cache
From: Liu Yuan <namei.unix@gmail.com>
Content-Type: multipart/alternative; boundary=20cf30549ed9318e30049d9e7195
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jaxboe@fusionio.com, akpm@linux-foundation.org, fengguang.wu@intel.com

--20cf30549ed9318e30049d9e7195
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Mar 3, 2011 at 9:50 AM, KOSAKI Motohiro <
kosaki.motohiro@jp.fujitsu.com> wrote:

> > [Summery]
> >
> > In order to evaluate page cache efficiency, system admins are happy to
> > know whether a block of data is cached for subsequent use, or whether
> > the page is read-in but seldom used. This patch extends an effort to
> > provide such kind of information. We adds three counters, which are
> > exported to the user space, for the Page Cache that is almost
> > transparent to the applications. This would benifit some heavy page
> > cache users that might try to tune the performance in hybrid storage
> > situation.
>
> I think you need to explain exact and concrete use-case. Typically,
> cache-hit ratio doesn't help administrator at all. because merely backup
> operation (eg. cp, dd, et al) makes prenty cache-miss. But it is no sign
> of memory shortage. Usually, vmscan stastics may help memroy utilization
> obzavation.
>
> Plus, as ingo said, you have to consider to use trancepoint framework
> at first. Because, it is zero cost if an admin don't enable such
> tracepoint.
>
>
Thanks very much for your comments.

Yeah, we'er going to try tracepoint and perf as Ingo said.


> At last, I don't think disk_stats have to have page cache stastics. It
> seems
> slightly layer violation.
>
> Thanks.
>
>
This is the starting point of the patch set, so I simply embedded the
structure into the existing infrastructure. This did saved me a lot of
effort because disk_stats is a good place to collect stats on _partition_
basis. Anyway, as you pointed out, this is kind of the mess.

Thanks,
Yuan

--20cf30549ed9318e30049d9e7195
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Mar 3, 2011 at 9:50 AM, KOSAKI M=
otohiro <span dir=3D"ltr">&lt;<a href=3D"mailto:kosaki.motohiro@jp.fujitsu.=
com">kosaki.motohiro@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote cl=
ass=3D"gmail_quote" style=3D"margin: 0pt 0pt 0pt 0.8ex; border-left: 1px so=
lid rgb(204, 204, 204); padding-left: 1ex;">
<div class=3D"im">&gt; [Summery]<br>
&gt;<br>
&gt; In order to evaluate page cache efficiency, system admins are happy to=
<br>
&gt; know whether a block of data is cached for subsequent use, or whether<=
br>
&gt; the page is read-in but seldom used. This patch extends an effort to<b=
r>
&gt; provide such kind of information. We adds three counters, which are<br=
>
&gt; exported to the user space, for the Page Cache that is almost<br>
&gt; transparent to the applications. This would benifit some heavy page<br=
>
&gt; cache users that might try to tune the performance in hybrid storage<b=
r>
&gt; situation.<br>
<br>
</div>I think you need to explain exact and concrete use-case. Typically,<b=
r>
cache-hit ratio doesn&#39;t help administrator at all. because merely backu=
p<br>
operation (eg. cp, dd, et al) makes prenty cache-miss. But it is no sign<br=
>
of memory shortage. Usually, vmscan stastics may help memroy utilization<br=
>
obzavation.<br>
<br>
Plus, as ingo said, you have to consider to use trancepoint framework<br>
at first. Because, it is zero cost if an admin don&#39;t enable such tracep=
oint.<br>
<br></blockquote><div><br>Thanks very much for your comments.<br><br>Yeah, =
we&#39;er going to try tracepoint and perf as Ingo said.<br>=A0</div><block=
quote class=3D"gmail_quote" style=3D"margin: 0pt 0pt 0pt 0.8ex; border-left=
: 1px solid rgb(204, 204, 204); padding-left: 1ex;">

At last, I don&#39;t think disk_stats have to have page cache stastics. It =
seems<br>
slightly layer violation.<br>
<br>
Thanks.<br>
<br></blockquote><div><br>This is the starting point of the patch set, so I=
 simply embedded the structure into the existing infrastructure. This did s=
aved me a lot of effort because disk_stats is a good place to collect stats=
 on _partition_=A0 basis. Anyway, as you pointed out, this is kind of the m=
ess.<br>
</div></div><br>Thanks,<br>Yuan<br>

--20cf30549ed9318e30049d9e7195--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
