Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 876EC6B0031
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 18:17:08 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id jt11so9168415pbb.11
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 15:17:08 -0800 (PST)
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
        by mx.google.com with ESMTPS id s7si15290391pae.330.2014.02.04.15.17.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 15:17:07 -0800 (PST)
Received: by mail-pa0-f50.google.com with SMTP id kp14so9088248pab.23
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 15:17:07 -0800 (PST)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Sebastian Capella <sebastian.capella@linaro.org>
In-Reply-To: <1498007.FMXxByppC2@vostro.rjw.lan>
References: <1391546631-7715-1-git-send-email-sebastian.capella@linaro.org>
 <1391546631-7715-4-git-send-email-sebastian.capella@linaro.org>
 <1498007.FMXxByppC2@vostro.rjw.lan>
Message-ID: <20140204231710.31169.6504@capellas-linux>
Subject: Re: [PATCH v7 3/3] PM / Hibernate: use name_to_dev_t to parse resume
Date: Tue, 04 Feb 2014 15:17:10 -0800
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>

Quoting Rafael J. Wysocki (2014-02-04 13:39:43)
> On Tuesday, February 04, 2014 12:43:51 PM Sebastian Capella wrote:
> > +     if (name =3D=3D NULL)
> What about "if (!name)"?
> > +     if (res !=3D 0) {
> What about "if (res)"?

Changed, thanks!

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
