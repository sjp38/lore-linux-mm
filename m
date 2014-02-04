Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id BAA846B0031
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 18:22:20 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id kp14so9180284pab.37
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 15:22:20 -0800 (PST)
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
        by mx.google.com with ESMTPS id sj5si26488082pab.81.2014.02.04.15.22.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 15:22:19 -0800 (PST)
Received: by mail-pd0-f174.google.com with SMTP id z10so8818156pdj.19
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 15:22:19 -0800 (PST)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Sebastian Capella <sebastian.capella@linaro.org>
In-Reply-To: <20140204223733.30015.23993@capellas-linux>
References: <1391546631-7715-1-git-send-email-sebastian.capella@linaro.org>
 <1391546631-7715-3-git-send-email-sebastian.capella@linaro.org>
 <9487103.2jnJmCRm9n@vostro.rjw.lan>
 <20140204223733.30015.23993@capellas-linux>
Message-ID: <20140204232222.31169.83206@capellas-linux>
Subject: Re: [PATCH v7 2/3] trivial: PM / Hibernate: clean up checkpatch in
 hibernate.c
Date: Tue, 04 Feb 2014 15:22:22 -0800
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Capella <sebastian.capella@linaro.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>

Quoting Sebastian Capella (2014-02-04 14:37:33)
> Quoting Rafael J. Wysocki (2014-02-04 13:36:29)
> > >  static int __init resumedelay_setup(char *str)
> > >  {
> > > -     resume_delay =3D simple_strtoul(str, NULL, 0);
> > > +     int ret =3D kstrtoint(str, 0, &resume_delay);
> > > +     /* mask must_check warn; on failure, leaves resume_delay unchan=
ged */
> > > +     (void)ret;

One unintended consequence of this change is that it'll now accept a
negative integer parameter.  I'll rework this to have the same behavior
as before.

BTW, one question, is the __must_check really needed on kstrtoint?
Wouldn't it be acceptable to rely on kstrtoint to not update resume_delay
if it's unable to parse an integer out of the string?  Couldn't that be
a sufficient effect without requiring checking the return?

Thanks,

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
