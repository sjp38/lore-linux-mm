Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f172.google.com (mail-ea0-f172.google.com [209.85.215.172])
	by kanga.kvack.org (Postfix) with ESMTP id F3FCB6B0038
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 18:49:00 -0500 (EST)
Received: by mail-ea0-f172.google.com with SMTP id l9so3112903eaj.3
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 15:49:00 -0800 (PST)
Received: from v094114.home.net.pl (v094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id s6si45664358eel.14.2014.02.04.15.48.59
        for <linux-mm@kvack.org>;
        Tue, 04 Feb 2014 15:48:59 -0800 (PST)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH v7 2/3] trivial: PM / Hibernate: clean up checkpatch in hibernate.c
Date: Wed, 05 Feb 2014 01:03:29 +0100
Message-ID: <1593382.PUxxx0NMeh@vostro.rjw.lan>
In-Reply-To: <20140204232222.31169.83206@capellas-linux>
References: <1391546631-7715-1-git-send-email-sebastian.capella@linaro.org> <20140204223733.30015.23993@capellas-linux> <20140204232222.31169.83206@capellas-linux>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Capella <sebastian.capella@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>

On Tuesday, February 04, 2014 03:22:22 PM Sebastian Capella wrote:
> Quoting Sebastian Capella (2014-02-04 14:37:33)
> > Quoting Rafael J. Wysocki (2014-02-04 13:36:29)
> > > >  static int __init resumedelay_setup(char *str)
> > > >  {
> > > > -     resume_delay = simple_strtoul(str, NULL, 0);
> > > > +     int ret = kstrtoint(str, 0, &resume_delay);
> > > > +     /* mask must_check warn; on failure, leaves resume_delay unchanged */
> > > > +     (void)ret;
> 
> One unintended consequence of this change is that it'll now accept a
> negative integer parameter.

Well, what about using kstrtouint(), then?

> I'll rework this to have the same behavior as before.
> 
> BTW, one question, is the __must_check really needed on kstrtoint?
> Wouldn't it be acceptable to rely on kstrtoint to not update resume_delay
> if it's unable to parse an integer out of the string?  Couldn't that be
> a sufficient effect without requiring checking the return?

Well, kstrtoint() is used in some security-sensitive places AFAICS, so it
really is better to check its return value in general.  The __must_check
reminds people about that.

Thanks!

-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
