Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 39CB98D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 12:21:33 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <fe3b936e-a670-4d8c-804e-faf1d2ea4741@default>
Date: Fri, 11 May 2012 09:21:10 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: is there a "lru_cache_add_anon_tail"?
References: <66ea94b0-2e40-44d1-9621-05f2a8257298@default>
 <CAHGf_=pDKciwPX4G0yJjzc0xmuqiSg=yHB20btJSYhN9cA7gug@mail.gmail.com>
In-Reply-To: <CAHGf_=pDKciwPX4G0yJjzc0xmuqiSg=yHB20btJSYhN9cA7gug@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-mm@kvack.org

> From: KOSAKI Motohiro [mailto:kosaki.motohiro@gmail.com]
> Subject: Re: is there a "lru_cache_add_anon_tail"?
>=20
> On Thu, May 10, 2012 at 12:13 PM, Dan Magenheimer
> <dan.magenheimer@oracle.com> wrote:
> > (Still working on allowing zcache to "evict" swap pages...)
> >
> > Apologies if I got head/tail reversed as used by the
> > lru queues... the "directional sense" of the queues is
> > not obvious so I'll describe using different terminology...
> >
> > If I have an anon page and I would like to add it to
> > the "reclaim soonest" end of the queue instead of the
> > "most recently used so don't reclaim it for a long time"
> > end of the queue, does an equivalent function similar to
> > lru_cache_add_anon(page) exist?
> >
>=20
> AFAIK, no exist.
> rotate_reclaimable_page() has similar requirement, but I doubt
> you can reuse it. maybe you need new function by yourself.

Thanks for the pointer!  It looks like I can extract
the code I need from there.
=20
> But note, many people dislike add_anon_tail feature. -ck patch had
> swap prefetch patch and it made performance decrease. I'm not
> sure it is good improvemnt for zcache....

I understand.  I think it does make sense for this
usage in zcache but will describe it when I am ready
to post an RFC.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
