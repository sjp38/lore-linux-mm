Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 3F1706B0044
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 15:58:08 -0400 (EDT)
Received: by wgbds10 with SMTP id ds10so3433093wgb.26
        for <linux-mm@kvack.org>; Mon, 26 Mar 2012 12:58:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120326194435.GW5906@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
	<1332783986-24195-12-git-send-email-aarcange@redhat.com>
	<1332786353.16159.173.camel@twins>
	<4F70C365.8020009@redhat.com>
	<20120326194435.GW5906@redhat.com>
Date: Mon, 26 Mar 2012 12:58:05 -0700
Message-ID: <CA+55aFwk0Etg_UhoZcKsfFJ7PQNLdQ58xxXiwcA-jemuXdZCZQ@mail.gmail.com>
Subject: Re: [PATCH 11/39] autonuma: CPU follow memory algorithm
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: multipart/alternative; boundary=001636c5b7aeed121904bc2aca8b
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hillf Danton <dhillf@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Dan Smith <danms@us.ibm.com>, Paul Turner <pjt@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Lai Jiangshan <laijs@cn.fujitsu.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, Bharata B Rao <bharata.rao@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org

--001636c5b7aeed121904bc2aca8b
Content-Type: text/plain; charset=ISO-8859-1

On Mar 26, 2012 12:45 PM, "Andrea Arcangeli" <aarcange@redhat.com> wrote:
>
> As I wrote in the comment before the function, math speaking, this
> looks like O(N) but it is O(1), not O(N) nor O(N^2). This is because N
> = NR_CPUS = 1.

That's just stupid sophistry.

No, you can't just say that it's limited to some large constant, and thus
the same as O(1).

That's the worst kind of lie: something that's technically true if you look
at it a certain stupid way, but isn't actually true in practice.

It's clearly O(n) in number of CPUs, and people told you it can't go into
the scheduler. Stop arguing idiotic things. Just say you'll fix it, instead
of looking like a tool.

      Linus

--001636c5b7aeed121904bc2aca8b
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<p><br>
On Mar 26, 2012 12:45 PM, &quot;Andrea Arcangeli&quot; &lt;<a href=3D"mailt=
o:aarcange@redhat.com">aarcange@redhat.com</a>&gt; wrote:<br>
&gt;<br>
&gt; As I wrote in the comment before the function, math speaking, this<br>
&gt; looks like O(N) but it is O(1), not O(N) nor O(N^2). This is because N=
<br>
&gt; =3D NR_CPUS =3D 1.</p>
<p>That&#39;s just stupid sophistry.</p>
<p>No, you can&#39;t just say that it&#39;s limited to some large constant,=
 and thus the same as O(1).</p>
<p>That&#39;s the worst kind of lie: something that&#39;s technically true =
if you look at it a certain stupid way, but isn&#39;t actually true in prac=
tice.</p>
<p>It&#39;s clearly O(n) in number of CPUs, and people told you it can&#39;=
t go into the scheduler. Stop arguing idiotic things. Just say you&#39;ll f=
ix it, instead of looking like a tool.</p>
<p>=A0=A0=A0=A0=A0 Linus<br>
</p>

--001636c5b7aeed121904bc2aca8b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
