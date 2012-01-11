Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 6B92B6B005C
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 03:05:41 -0500 (EST)
Received: by yhoo21 with SMTP id o21so216713yho.14
        for <linux-mm@kvack.org>; Wed, 11 Jan 2012 00:05:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHGf_=odfZxYS+PcMfeJ2ddFm76+-KbOLNrjGBtoEdExdQmL3Q@mail.gmail.com>
References: <20120109181023.7c81d0be@annuminas.surriel.com>
 <4F0B7D1F.7040802@gmail.com> <4F0BABE0.8080107@redhat.com>
 <CAHGf_=qtpA5VTw5W0zaAhB2WCX1+-k59szTnDLnqDJeg+q9Jsw@mail.gmail.com> <CAHGf_=odfZxYS+PcMfeJ2ddFm76+-KbOLNrjGBtoEdExdQmL3Q@mail.gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Wed, 11 Jan 2012 03:05:19 -0500
Message-ID: <CAHGf_=pnbOo6bGf3uxsCbn2YJ3XwpE79TDWdX2jRrUoE5Hkbdw@mail.gmail.com>
Subject: Re: [PATCH -mm] make swapin readahead skip over holes
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

2012/1/11 KOSAKI Motohiro <kosaki.motohiro@gmail.com>:
>> Also, I doubt current swap_cluster default is best value on nowadays.
>
> I meant, current average hdd spec is,
> =A0- average seek time: 8.5ms
> =A0- sequential access performance: about 60MB/sec
>
> so, we can eat free lunch up to 7MB ~=3D 60(MB/sec) * 1000 / 8.5(ms).

Bah! I'm moron.
the correct fomura is,

500KB =3D 60(MB/sec) / 1000(msec/ssec) *8.5 (ms)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
