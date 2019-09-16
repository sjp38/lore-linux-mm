Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90A13C4CED0
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 11:46:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55B7B20665
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 11:46:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Nc6aTwku"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55B7B20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF8276B0005; Mon, 16 Sep 2019 07:46:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C82106B0006; Mon, 16 Sep 2019 07:46:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B48B86B0007; Mon, 16 Sep 2019 07:46:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0029.hostedemail.com [216.40.44.29])
	by kanga.kvack.org (Postfix) with ESMTP id 8D0246B0005
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 07:46:10 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 396722C9D
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 11:46:10 +0000 (UTC)
X-FDA: 75940605300.17.trail27_35cf592c11b13
X-HE-Tag: trail27_35cf592c11b13
X-Filterd-Recvd-Size: 4218
Received: from mail-lj1-f194.google.com (mail-lj1-f194.google.com [209.85.208.194])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 11:46:09 +0000 (UTC)
Received: by mail-lj1-f194.google.com with SMTP id f1so1906479ljc.2
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 04:46:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=9nRUSFMMMTBahdL0zPsPWqmNCPwIReETeD7CWvMjV44=;
        b=Nc6aTwkuTLYeviVZiPgrSANSpK9oSoASeyMnRU9wlmjBEyx8j2k5WjNthGj3sODHUH
         3x3nYr7OiAgNfhU4AiF9tjp1AHwFWyYFx3K64PyEsEXuc4BtxFhhewxCagCxMshMwkK3
         6i91P2EdKMspueFMWdfOsQlZQoBXujNSSzBwNLDVdD4ESklhqFs2H7BOBKQcsoY5gR2U
         2sJM6yVOUocsv/taUDwfwZPn+GvfEWtfvTZPPw20nG5S84cPsgOWJSIhoY1BlsGXNMC1
         8TrzG9x/amuAMgLyrj3iruOjXz0yXhO4lqADmzSnlDL01ou0jbBrniO0x+q0lzSaKa+v
         CAgg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=9nRUSFMMMTBahdL0zPsPWqmNCPwIReETeD7CWvMjV44=;
        b=RpCqD47lLMYLOPVjrjNlImHSGkBT0OEopj4+Izp+MTYiV6qUvkoCdT4bB4oqsCMScW
         LxSQbK6Lseo0/1yGrVWwjIDN8txrW0cS0KXEycbvRe3B01d17Agru4wAVHb15OTTX3zb
         SzdohdEHBDhM+APxTNAWIrUOonwsI6LT04cbHeJo5c2vYGSi0VEYnUsYFisrPw8ZoMiZ
         t86Puq7BayGA7nEhfK6ffiyN6ZwfCk2L/CzVY+lpNM4Bl0bw/30R/tOP89UbOi/KEZt6
         EeSyRHtA2hdoMKjWW0FeVcmAMW/S6TLr6w7L7F3iRl+iatpAQi5memNUEwQWfgSR1oMA
         sA+w==
X-Gm-Message-State: APjAAAUXdjGGtp3kj2O1Ye+EOIVblGE26ZJKZk/iZV1JOF5f8FlzvZWL
	fRV7qSBQjcl9OJfwDK8Ql+oQr2B/zBd0tk2LWP8=
X-Google-Smtp-Source: APXvYqwsTh4KNDke38S9xtq8ckfHNlWDqiFIq+7xmbYbRI7/TBp6Cx+kO6rrDFD7rnp4zT1LzLB/Do1Fjhn/a104aA0=
X-Received: by 2002:a2e:9c99:: with SMTP id x25mr37293703lji.9.1568634368063;
 Mon, 16 Sep 2019 04:46:08 -0700 (PDT)
MIME-Version: 1.0
References: <20190902094540.12786-1-janne.karhunen@gmail.com>
 <20190909213938.GA105935@gmail.com> <CAE=NcraXOhGcPHh3cPxfaNjFXtPyDdSFa9hSrUSPfpFUmsxyMA@mail.gmail.com>
 <20190915202433.GC1704@sol.localdomain>
In-Reply-To: <20190915202433.GC1704@sol.localdomain>
From: Janne Karhunen <janne.karhunen@gmail.com>
Date: Mon, 16 Sep 2019 14:45:56 +0300
Message-ID: <CAE=NcrbaJD4CaUvg1tmNSSKjkG-EizNM7GUaztA0=fiUCo03Cg@mail.gmail.com>
Subject: Re: [PATCH 1/3] ima: keep the integrity state of open files up to date
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org, 
	Mimi Zohar <zohar@linux.ibm.com>, linux-mm@kvack.org, viro@zeniv.linux.org.uk, 
	Konsta Karsisto <konsta.karsisto@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.163748, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Sep 15, 2019 at 11:24 PM Eric Biggers <ebiggers@kernel.org> wrote:

> > > This still doesn't make it crash-safe.  So why is it okay?
> >
> > If Android is the load, this makes it crash safe 99% of the time and
> > that is considerably better than 0% of the time.
> >
>
> Who will use it if it isn't 100% safe?

I suppose anyone using mutable data with IMA appraise should, unless
they have a redundant power supply and a kernel that never crashes. In
a way this is like asking if the ima-appraise should be there for
mutable data at all. All this is doing is that it improves the crash
recovery reliability without taking anything away.

Anyway, I think I'm getting along with my understanding of the page
writeback slowly and the journal support will eventually be there at
least as an add-on patch for those that want to use it and really need
the last 0.n% reliability. Note that even without that patch you can
build ima-appraise based systems that are 99.999% reliable just by
having the patch we're discussing here. Without it you would be orders
of magnitude worse off. All we are doing is that we give it a fairly
good chance to recover instead of giving up without even trying.

That said, I'm not sure the 100% crash recovery is ever guaranteed in
any Linux system. We just have to do what we can, no?


--
Janne

