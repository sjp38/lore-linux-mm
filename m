Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FFF2C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 01:04:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 156F120700
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 01:04:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="T6duP2l9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 156F120700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A24596B0006; Thu, 28 Mar 2019 21:04:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D3466B0007; Thu, 28 Mar 2019 21:04:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C2726B0008; Thu, 28 Mar 2019 21:04:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0FF6B0006
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 21:04:14 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id k13so685452qtc.23
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 18:04:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=qLvJpD5VtGmd85WRPzy2IOxg0BGUhYP6z/BWmT7XiCA=;
        b=Qe//UZ1FKg8MhYkTVGEsYgdAmfVS2G6e+rwDIWyjTU2IBgHaxd52IS0FWLZhHiedW4
         D3GbBXc4a1dQGoDS+sj6orYHRSpbBGukF03RdfQJOc6xmX6+OjpyNOCJrz8D4rFEopjT
         b7MKH3cG8y2Cz0QSgjexICX008I++9eTJWcIkzeO+0amkrv0t6eLGJB6CuljTrlqyfSV
         SFQN+ZyBSwJLa1llUVwso2NMbBDFxsKAzLQyuhiyO/0CA8l/q4/2lZc58n/CfS+yXBXF
         SZXcHy1YxRg+GZtuCCr7gn74ekZmkffHYt5XFRPYLS6H47gOz2A7zTdt5Ub32SqSRBN2
         RXCw==
X-Gm-Message-State: APjAAAU7s25XmjilfdmAH8YhnLD0getlvwGu1R+77CU8a+NFZdaMyiJ3
	aG3BFkYwOq5y27mViSkAPgbd9+Oc9YGXfL6+57tHzE6F9sk7LfcYSuKrhP2QgMIybeNsewPkLZk
	AyNQ7GxenQ1x48P+99s/YFUTBFi7EY/Ap2jneq1ckcY6f9ReCksS9UHr2eLMBXyE3Eg==
X-Received: by 2002:ac8:f27:: with SMTP id e36mr24825226qtk.27.1553821454197;
        Thu, 28 Mar 2019 18:04:14 -0700 (PDT)
X-Received: by 2002:ac8:f27:: with SMTP id e36mr24825202qtk.27.1553821453701;
        Thu, 28 Mar 2019 18:04:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553821453; cv=none;
        d=google.com; s=arc-20160816;
        b=UjjZkikHtPG0jhbqibh/t6RVPLNlSthL9HGhx8YwAHLrCvc/E/Ydt3kmpnFOAurBSb
         HxtfM3kYBUnH0haFDKPmq8WvOggarzDM55WhfAA5Us4H7zy30fCwhjoFbTKAU88bKUVD
         2pmsm4ZRvX3v2rUbi46agrj20cP11TbK5yYgivFAIVZEoFgvJ1uAWiZjcUZgb4MDwFGr
         STgB//1VlsKsgXxRr32pOaNBKfFQ3oeaVyIB4SvzU6IIPuF2csSDZNPeyZs8QgaDlZJr
         QwmN2/gM5+F9KCaTW5paAMC5dUf+3P5fvyV4N1TU846m3e5NJz1fLtMXMF5JECwI7y7L
         nYzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=qLvJpD5VtGmd85WRPzy2IOxg0BGUhYP6z/BWmT7XiCA=;
        b=I0mGn1071eZOLaRzu9e2EyA6St4khQc7rOgBbtKpMdmaOhauggldnyjIzxjzFytpJX
         03q9zQTGwkjP8Tar10mVus5euNprdQAUN0u41rjq4y+dz0A1Vc7hdIufer9Cx/cdiNJm
         bEPkQ8vUWM/n8knwRNfwVGmhIeqF/kc+5rS5eSZllL0LsSO4q23qyYjw8rWN5YfynUn7
         EsUBNBAaYagJSUaK5E//GVTrB41QFsv6IsXE7ZmoFW8OtaFVtrwJNd9qu+gK8GTRcFG2
         P5DEKi4V6Ic9T202beQXCIDTwdT15lFZB3nwNbli0gUdn7SF/U5mdBrsAXKLCJkf2RWG
         Qr8g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=T6duP2l9;
       spf=pass (google.com: domain of vincent.mc.li@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vincent.mc.li@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h12sor583346qth.20.2019.03.28.18.04.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Mar 2019 18:04:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of vincent.mc.li@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=T6duP2l9;
       spf=pass (google.com: domain of vincent.mc.li@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vincent.mc.li@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qLvJpD5VtGmd85WRPzy2IOxg0BGUhYP6z/BWmT7XiCA=;
        b=T6duP2l9Qfj6Gx11JdzcV3DBT6F21EIPjf8eix7uAQ16bl8AGXrlzHrZNc5Ej1ApIC
         KTdkiSiS86LXbFW8XleLeuA5nLxaqmjgWBACd9Aun4WRVSajPrwXo7LCkJsnCyg7g/rq
         e2olkqWgxe+lRzzasc583vhtnU1b/syWyXW0lYqbKIB0tWUq3hY9ALyMAd5NutjLm07w
         SVoT+bq4oswBax3iJGTeNW6Oc+WfiWnPx57EMvRFhgnFvKQVfKiMqyUKjD4KjMy6MWAi
         obLdzLbG3yI2DMperFoHl2ak1P3xZZTur/o2VfBFG92i9NoWzQnOwnA+PRbjXg/cJR4b
         ko9w==
X-Google-Smtp-Source: APXvYqzdS0mmjOEg9m9D3hqyflNoUXl5SJGeDWK/v3XEo4e9pELE4hrvhDnaDbdj090moRojWy3432aeabDcMY+r0Wg=
X-Received: by 2002:ac8:2e99:: with SMTP id h25mr39847974qta.166.1553821453422;
 Thu, 28 Mar 2019 18:04:13 -0700 (PDT)
MIME-Version: 1.0
References: <fcf5dd0b-8e96-7512-b76a-65a74e5fd52f@I-love.SAKURA.ne.jp>
 <CAK3+h2wB2x4p976cqA5UPXhz5bZ6mjK98xB8nGQ8hkBoW02k7g@mail.gmail.com> <201903290006.x2T06fWZ001228@www262.sakura.ne.jp>
In-Reply-To: <201903290006.x2T06fWZ001228@www262.sakura.ne.jp>
From: Vincent Li <vincent.mc.li@gmail.com>
Date: Thu, 28 Mar 2019 18:04:02 -0700
Message-ID: <CAK3+h2xppfdTSd2Gc=Qfd2oDp+Z+VyiTf_CQhn4JyB7UqsiGUQ@mail.gmail.com>
Subject: Re: sysrq key f to trigger OOM manually
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 5:06 PM Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> > On Thu, Mar 28, 2019 at 3:46 PM Tetsuo Handa
> > <penguin-kernel@i-love.sakura.ne.jp> wrote:
> > >
> > > On 2019/03/29 6:37, Vincent Li wrote:
> > > > Hi,
> > > >
> > > > not sure if this is the right place, I tried to use echo f >
> > > > /proc/sysrq-trigger to manually trigger OOM, the OOM killer is
> > > > triggered to kill a process, does it make sense to trigger OOM killer
> > > > manually but not actually kill the process, this could be useful to
> > > > diagnosis problem without actually killing a process in production
> > > > box.
> > >
> > > Why not use "/usr/bin/top -o %MEM" etc. ?
> > > Reading from /proc will give you more information than from SysRq.
> >
> > I am interested to see OOM output including swap entries per process
> > in swap partition and all
> > the other kernel internal virtual memory stats, I find it useful than
> > top or free or /proc/meminfo
> >
>
> Please read http://man7.org/linux/man-pages/man5/proc.5.html and/or
> https://www.kernel.org/doc/Documentation/filesystems/proc.txt .


Thanks, I know I can get lots of information from /proc/<pid>/, but I
like the format/style that OOM dumps since I
don't have to use some kind of script to parse out the /proc/<pid>,
plus, OOM also dumps node/zone/page orders....information all
together, lots of useful information so I can have big picture on the
memory usage of the system.

