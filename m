Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3CF6C6B0169
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 21:05:05 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p7D14xdn018667
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 18:04:59 -0700
Received: from yws29 (yws29.prod.google.com [10.192.19.29])
	by wpaz1.hot.corp.google.com with ESMTP id p7D14qsH001735
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 18:04:58 -0700
Received: by yws29 with SMTP id 29so2388332yws.30
        for <linux-mm@kvack.org>; Fri, 12 Aug 2011 18:04:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110809170118.880377f8.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110722171540.74eb9aa7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110808124333.GA31739@redhat.com>
	<20110809083345.46cbc8de.kamezawa.hiroyu@jp.fujitsu.com>
	<20110809080159.GA32015@redhat.com>
	<20110809170118.880377f8.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 12 Aug 2011 18:04:52 -0700
Message-ID: <CALWz4iwm+q-LcMjfaCmjy1Z-4tmO6Cpx2nA4Ems_RKsyWQDq0w@mail.gmail.com>
Subject: Re: [PATCH v3] memcg: add memory.vmscan_stat
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <jweiner@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, abrestic@google.com

On Tue, Aug 9, 2011 at 1:01 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> On Tue, 9 Aug 2011 10:01:59 +0200
> Johannes Weiner <jweiner@redhat.com> wrote:
>
> > On Tue, Aug 09, 2011 at 08:33:45AM +0900, KAMEZAWA Hiroyuki wrote:
> > > On Mon, 8 Aug 2011 14:43:33 +0200
> > > Johannes Weiner <jweiner@redhat.com> wrote:
> > > > On a non-technical note: as Ying Han and I were the other two peopl=
e
> > > > working on reclaim and statistics, it really irks me that neither o=
f
> > > > us were CCd on this. =A0Especially on such a controversial change.
> > >
> > > I always drop CC if no reply/review comes.
> >
> > There is always the possibility that a single mail in an otherwise
> > unrelated patch series is overlooked (especially while on vacation ;).
> > Getting CCd on revisions and -mm inclusion is a really nice reminder.
> >
> > Unless there is a really good reason not to (is there ever?), could
> > you please keep CCs?
> >
>
> Ok, if you want, I'll CC always.
> I myself just don't like to get 3 copies of mails when I don't have
> much interests ;)
>
> Thanks,
> -Kame

Hi Kame, Johannes,

Sorry for getting into this thread late and here are some comments:

There are few patches that we've been working on which could change
the memcg reclaim path quite bit. I wonder if they have chance to be
merged later, this patch might need to be adjusted accordingly as
well. If the ABI needs to be changed, that would be hard.

There is a patch Andrew (abrestic@) has been testing which adds the
same memory.vmscan_stat, but based on some page reclaim patches.
(Mainly the memcg-aware global reclaim from Johannes ). And it does
adjust to the hierarchical reclaim change as Johannes mentioned.

So, may I suggest us to hold on this patch for now? while the other
page reclaim changes being settled, we can then add it in.

Thanks

--Ying





>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
