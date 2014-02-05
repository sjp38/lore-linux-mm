Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 689E46B0035
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 19:24:12 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kp14so9172683pab.34
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 16:24:12 -0800 (PST)
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
        by mx.google.com with ESMTPS id xu6si26656852pab.51.2014.02.04.16.24.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 16:24:11 -0800 (PST)
Received: by mail-pd0-f178.google.com with SMTP id y13so8959588pdi.9
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 16:24:10 -0800 (PST)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Sebastian Capella <sebastian.capella@linaro.org>
In-Reply-To: <2342041.V7doIJk0XQ@vostro.rjw.lan>
References: <1391546631-7715-1-git-send-email-sebastian.capella@linaro.org>
 <1593382.PUxxx0NMeh@vostro.rjw.lan> <20140205000642.6803.8182@capellas-linux>
 <2342041.V7doIJk0XQ@vostro.rjw.lan>
Message-ID: <20140205002413.7648.33035@capellas-linux>
Subject: Re: [PATCH v7 2/3] trivial: PM / Hibernate: clean up checkpatch in
 hibernate.c
Date: Tue, 04 Feb 2014 16:24:13 -0800
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>

Quoting Rafael J. Wysocki (2014-02-04 16:28:13)
> On Tuesday, February 04, 2014 04:06:42 PM Sebastian Capella wrote:
> > Quoting Rafael J. Wysocki (2014-02-04 16:03:29)
> > > On Tuesday, February 04, 2014 03:22:22 PM Sebastian Capella wrote:
> > > > Quoting Sebastian Capella (2014-02-04 14:37:33)
> > > > > Quoting Rafael J. Wysocki (2014-02-04 13:36:29)
> > > > > > >  static int __init resumedelay_setup(char *str)
> > > > > > >  {
> > > > > > > -     resume_delay =3D simple_strtoul(str, NULL, 0);
> > > > > > > +     int ret =3D kstrtoint(str, 0, &resume_delay);
> > > > > > > +     /* mask must_check warn; on failure, leaves resume_dela=
y unchanged */
> > > > > > > +     (void)ret;
> > > > =

> > > > One unintended consequence of this change is that it'll now accept a
> > > > negative integer parameter.
> > > =

> > > Well, what about using kstrtouint(), then?
> > I was thinking of doing something like:
> > =

> >       int delay, res;
> >       res =3D kstrtoint(str, 0, &delay);
> >       if (!res && delay >=3D 0)
> >               resume_delay =3D delay;
> >       return 1;
> =

> It uses simple_strtoul() for a reason.  You can change the type of resume=
_delay
> to match, but the basic question is:
> =

> Why exactly do you want to change that thing?

This entire patch is a result of a single checkpatch warning from a printk
that I indented.

I was hoping to be helpful by removing all of the warnings from this
file, since I was going to have a separate cleanup patch for the printk.

I can see this is not a good direction.

Would it be better also to leave the file's printks as they were and drop
the cleanup patch completely?

Thanks,

Sebastian


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
