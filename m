Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id D062F6B005A
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 14:49:14 -0500 (EST)
Received: by vcbfl11 with SMTP id fl11so642668vcb.14
        for <linux-mm@kvack.org>; Tue, 17 Jan 2012 11:49:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F15CC56.90309@redhat.com>
References: <1326788038-29141-1-git-send-email-minchan@kernel.org>
	<1326788038-29141-2-git-send-email-minchan@kernel.org>
	<CAOJsxLHGYmVNk7D9NyhRuqQDwquDuA7LtUtp-1huSn5F-GvtAg@mail.gmail.com>
	<4F15A34F.40808@redhat.com>
	<alpine.LFD.2.02.1201172044310.15303@tux.localdomain>
	<4F15CC56.90309@redhat.com>
Date: Tue, 17 Jan 2012 21:49:13 +0200
Message-ID: <CAOJsxLFzuvYm2pHZP--=nx3qGatzgfT6Dii49gzJwzxOtzniTg@mail.gmail.com>
Subject: Re: [RFC 1/3] /dev/low_mem_notify
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, leonid.moiseichuk@nokia.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, rientjes@google.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Marcelo Tosatti <mtosatti@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ronen Hod <rhod@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Tue, Jan 17, 2012 at 9:30 PM, Rik van Riel <riel@redhat.com> wrote:
> Looks like a nice extensible interface to me.
>
> The only thing is, I expect we will not want to wake
> up processes most of the time, when there is no memory
> pressure, because that would just waste battery power
> and/or cpu time that could be used for something else.
>
> The desire to avoid such wakeups makes it harder to
> wake up processes at arbitrary points set by the API.

Sure. You could either bump up the threshold or use Minchan's hooks - or bo=
th.

On Tue, Jan 17, 2012 at 9:30 PM, Rik van Riel <riel@redhat.com> wrote:
> Another issue is that we might be running two programs
> on the system, each with a different threshold for
> "lets free some of my cache". =A0Say one program sets
> the threshold at 20% free/cache memory, the other
> program at 10%.
>
> We could end up with the first process continually
> throwing away its caches, while the second process
> never gives its unused memory back to the kernel.
>
> I am not sure what the right thing to do would be...

One option is to use per-process thresholds on RSS, for example, and
also support system-wide thresholds.

That said, I'd really like to see the N9 and Android policies
supported with this ABI. It's much easier to make it generic once we
support real-world use cases.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
