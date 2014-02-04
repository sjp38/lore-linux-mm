Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7D5496B0035
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 17:37:36 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id hz1so9000484pad.8
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 14:37:36 -0800 (PST)
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
        by mx.google.com with ESMTPS id l8si26352558pao.210.2014.02.04.14.37.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 14:37:35 -0800 (PST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so9144640pab.33
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 14:37:35 -0800 (PST)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Sebastian Capella <sebastian.capella@linaro.org>
In-Reply-To: <9487103.2jnJmCRm9n@vostro.rjw.lan>
References: <1391546631-7715-1-git-send-email-sebastian.capella@linaro.org>
 <1391546631-7715-3-git-send-email-sebastian.capella@linaro.org>
 <9487103.2jnJmCRm9n@vostro.rjw.lan>
Message-ID: <20140204223733.30015.23993@capellas-linux>
Subject: Re: [PATCH v7 2/3] trivial: PM / Hibernate: clean up checkpatch in
 hibernate.c
Date: Tue, 04 Feb 2014 14:37:33 -0800
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>

Quoting Rafael J. Wysocki (2014-02-04 13:36:29)
> Well, this isn't a trivial patch.

I'll remove the trivial, thanks!

Quoting Rafael J. Wysocki (2014-02-04 13:36:29)
> On Tuesday, February 04, 2014 12:43:50 PM Sebastian Capella wrote:
> > +     while (1)
> > +             ;
> Please remove this change from the patch.  I don't care about checkpatch
> complaining here.
> > +     while (1)
> > +             ;
> Same here.

Will do, thanks!

> > @@ -765,7 +762,7 @@ static int software_resume(void)
> >       if (isdigit(resume_file[0]) && resume_wait) {
> >               int partno;
> >               while (!get_gendisk(swsusp_resume_device, &partno))
> > -                     msleep(10);
> > +                     msleep(20);
> =

> That's the reason why it is not trivial.
> =

> First, the change being made doesn't belong in this patch.

Thanks I'll separate it if it remains.

> Second, what's the problem with the original value?

The warning from checkpatch implies that it's misleading to
msleep < 20ms since msleep is using msec_to_jiffies + 1 for
the duration.  In any case, this is polling for devices discovery to
complete.  It is used when resumewait is specified on the command
line telling hibernate to wait for the resume device to appear.

> > -static ssize_t image_size_show(struct kobject *kobj, struct kobj_attri=
bute *attr,
> > +static ssize_t image_size_show(struct kobject *kobj,
> > +                            struct kobj_attribute *attr,
> Why can't you leave the code as is here?
> > -static ssize_t image_size_store(struct kobject *kobj, struct kobj_attr=
ibute *attr,
> > +static ssize_t image_size_store(struct kobject *kobj,
> > +                             struct kobj_attribute *attr,
> And here?

Purely long line cleanup. (>80 colunms)

> >  static int __init resumedelay_setup(char *str)
> >  {
> > -     resume_delay =3D simple_strtoul(str, NULL, 0);
> > +     int ret =3D kstrtoint(str, 0, &resume_delay);
> > +     /* mask must_check warn; on failure, leaves resume_delay unchange=
d */
> > +     (void)ret;
> =

> And that's not a trivial change surely?

I'll include this and the msleep as a separate, non-trivial checkpatch
cleanup patch if the changes remain after this discussion.

> =

> And why didn't you do (void)kstrtoint(str, 0, &resume_delay); instead?

Better thanks!

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
