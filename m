Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 46C826B0036
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 19:13:45 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id e51so2393533eek.28
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 16:13:44 -0800 (PST)
Received: from v094114.home.net.pl (v094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id d8si45712721eeh.179.2014.02.04.16.13.43
        for <linux-mm@kvack.org>;
        Tue, 04 Feb 2014 16:13:44 -0800 (PST)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH v7 2/3] trivial: PM / Hibernate: clean up checkpatch in hibernate.c
Date: Wed, 05 Feb 2014 01:28:13 +0100
Message-ID: <2342041.V7doIJk0XQ@vostro.rjw.lan>
In-Reply-To: <20140205000642.6803.8182@capellas-linux>
References: <1391546631-7715-1-git-send-email-sebastian.capella@linaro.org> <1593382.PUxxx0NMeh@vostro.rjw.lan> <20140205000642.6803.8182@capellas-linux>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Capella <sebastian.capella@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>

On Tuesday, February 04, 2014 04:06:42 PM Sebastian Capella wrote:
> Quoting Rafael J. Wysocki (2014-02-04 16:03:29)
> > On Tuesday, February 04, 2014 03:22:22 PM Sebastian Capella wrote:
> > > Quoting Sebastian Capella (2014-02-04 14:37:33)
> > > > Quoting Rafael J. Wysocki (2014-02-04 13:36:29)
> > > > > >  static int __init resumedelay_setup(char *str)
> > > > > >  {
> > > > > > -     resume_delay = simple_strtoul(str, NULL, 0);
> > > > > > +     int ret = kstrtoint(str, 0, &resume_delay);
> > > > > > +     /* mask must_check warn; on failure, leaves resume_delay unchanged */
> > > > > > +     (void)ret;
> > > 
> > > One unintended consequence of this change is that it'll now accept a
> > > negative integer parameter.
> > 
> > Well, what about using kstrtouint(), then?
> I was thinking of doing something like:
> 
> 	int delay, res;
> 	res = kstrtoint(str, 0, &delay);
> 	if (!res && delay >= 0)
> 		resume_delay = delay;
> 	return 1;

It uses simple_strtoul() for a reason.  You can change the type of resume_delay
to match, but the basic question is:

Why exactly do you want to change that thing?

-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
