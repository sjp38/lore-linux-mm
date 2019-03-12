Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A584C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 18:51:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF9F9206BA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 18:51:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brauner.io header.i=@brauner.io header.b="ReZ7TFra"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF9F9206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=brauner.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6AA468E0003; Tue, 12 Mar 2019 14:51:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6579B8E0002; Tue, 12 Mar 2019 14:51:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 521B48E0003; Tue, 12 Mar 2019 14:51:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id D78AD8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 14:51:09 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id x9so246003lji.18
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 11:51:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Mm1QjN0w8dacwGXEVgLh1zGRWMMMxD/FUwmSzd/yuf8=;
        b=JULdCHYM0gNZmcMQkq/lC7EK3U/lt27K90AYBaKMPYkDmsgOH3p4YbynarBQX0jtvu
         3FZYShWyO7FP6tPGyYATb9Czt9m77jW1syoJ59uFiWb6wJvafUgVlD1n8ILcjEBITEFb
         sxBIXME+g3ayZbBvFHVrU+ScDeZ1z1q7N31PxnX2kaDmhtcgsrwElVL7qnDx1dp5Cmjz
         6LfcxtM4Z8/dcEHMypwgcqkavlOAYS3tF0cJet3QEvwJQZm/RatEOkWROBKcRhkSorxE
         gQzn7DCGGBBTc2UZJrsX0Ik7sMem3RMJ49q62AR7WxXv7BdWnWHEuhjwO4+Q7/fJJ6Ng
         itCQ==
X-Gm-Message-State: APjAAAXyC2sbxWfeFpyXA4vJJl3GzUndCbZQXeLXNadHEORgiI7+DznP
	NNxhD65dNY/1MxtvHpYoF5YiDVb2S5j1hUkivHadqktchmZbfjtuCLlX/z4HUpmmDxeP9mWAxN/
	/2gld1cMBKkW9ewAhIVpznzPhd7eGZp28BotvxmxjXyOQIdHHf6jr7jPYkMOsLZdKNIb1gyrgZM
	M5GjU3McMnhZi3tLEBJDgKZVcnbwEnPD3J8Wjy/jIXifTynzmwz1IJoJRBkHLntR3+zaBD24beH
	wX2nXefVVpToru5zlkkOskfQk5DpWX+PMxZjlOCmhB55fRldHspeFV8a77e3ksERsEv9Tpmf1CS
	eEoIuOU78gtGa0ZWMNTyamdmmV1lESULZSA9quPcLar8+sRWy5K2gBqCLMX10SpfW5U5iXTF+Qo
	Y
X-Received: by 2002:a2e:9105:: with SMTP id m5mr21381728ljg.100.1552416668615;
        Tue, 12 Mar 2019 11:51:08 -0700 (PDT)
X-Received: by 2002:a2e:9105:: with SMTP id m5mr21381688ljg.100.1552416667713;
        Tue, 12 Mar 2019 11:51:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552416667; cv=none;
        d=google.com; s=arc-20160816;
        b=dH2aQEpyTx6JjHbRILHy4ENQEr5+KXuFJTDYoJA6HH4uOhI4VCjlSvdCfcOjq3Gxmm
         iNXEN8paYntsM630sM6M3rf1RZcEgeShtGPK66FYMRBfydkDs76flyIc1BUka0guKaUq
         h7nbtrQze3fYPE0cULO/qqwnGMbz3mMadbShrIyQPKdelkRZRr0Dg9AHgGwMS3HkFQsi
         BoNLxrUPDGjXWDQd2njBoco4/SikjFliy8SI8apObXC0zgcB9J/PXSTA6emPefEsaWlS
         kw2Bsim/3s+2Om3eEVGFIwlkL5lUKLSg15nFsPQcRZzNvCqDu5Al6smQOfzoHre0JJC7
         NxLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Mm1QjN0w8dacwGXEVgLh1zGRWMMMxD/FUwmSzd/yuf8=;
        b=okuh+p2MhhdQnLHcs+MvOzeUttFhqvWnT0rI76HKXciQzwsvsofijbsD2Bsz8/v6oS
         /lvPw/6IxVnNmsPzUwRc1ccMyguVqqU6As/yOsrc/8ueSAuCquM73jcG3jwEtlSf0q4Q
         s0m7QdWUK8L4N8qZYiJH31MH29+IjjdJWE/3R4Zs/5uYrxNheoGWyjoLcsw2mWYura5h
         pGIsi0lr7sL4hZQtv/qnI/7KcbRoIJb9gC1oDXkbg/DUwqi7DS+Hv234ir0/lleJA2PQ
         vhJAD/8yjN8xhA0wxSISoxI7HSHT3rCSMGazuimUImKhH5zdhRXyclyFkSlBGvFfJiJ1
         1jSw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=ReZ7TFra;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q17sor5636359ljg.42.2019.03.12.11.51.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 11:51:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=ReZ7TFra;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brauner.io; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Mm1QjN0w8dacwGXEVgLh1zGRWMMMxD/FUwmSzd/yuf8=;
        b=ReZ7TFratJ9POYe6uENAlwtgGehDAzQ2wCByC5K5jWadZKihhqNohXxG6TJQKQPbQM
         Z2fBsTi4n9dUsdHgFXbDNVqnCfzUp8UG4J4TXogC9BIeJE7mVvjgjdV2QKQ3EWDZsVcV
         0GWRm/8L5yezYHi9shNQtX5EWu81grR7bJQvyzJrys7kBYxQc3TCEXJvVb9cv3oR7YTA
         jRoAVYCvsLhSmCgM3v71misWrrC8WCrbGHvpbwr0Yw5zMIvqGbFjLKdxO/jWUO/eNMv5
         zkj8CKXLtQ2OxjJPT/o56vzm5sk5BpJ26RbliroOVQqmDBfM/pwErxR90ONVv/lB84ox
         F7IA==
X-Google-Smtp-Source: APXvYqw042Y405TkkYroyypqXMMWe0ijN5HML/93iYXw+M+g2oYOWyTaRT6QzClpgaL7ftG8FMaffrhutNYfqB9ApDI=
X-Received: by 2002:a2e:b014:: with SMTP id y20mr10013024ljk.116.1552416666852;
 Tue, 12 Mar 2019 11:51:06 -0700 (PDT)
MIME-Version: 1.0
References: <20190310203403.27915-1-sultan@kerneltoast.com>
 <20190311174320.GC5721@dhcp22.suse.cz> <20190311175800.GA5522@sultan-box.localdomain>
 <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
 <20190311204626.GA3119@sultan-box.localdomain> <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
 <20190312080532.GE5721@dhcp22.suse.cz> <20190312163741.GA2762@sultan-box.localdomain>
 <CAEe=Sxn_uayj48wo7oqf8mNZ7QAGJUQVmkPcHcuEGjA_Z8ELeQ@mail.gmail.com>
 <20190312174520.GA9276@sultan-box.localdomain> <CAEe=Sx=MxzBB46WxuwHTQcocBkx1UW+fmVOa3VWv_eUferzVYw@mail.gmail.com>
In-Reply-To: <CAEe=Sx=MxzBB46WxuwHTQcocBkx1UW+fmVOa3VWv_eUferzVYw@mail.gmail.com>
From: Christian Brauner <christian@brauner.io>
Date: Tue, 12 Mar 2019 19:50:56 +0100
Message-ID: <CAHrFyr7wJsNAQ_NPAsBDA-g7useeetgJ-MBod40SQAmf08sXJw@mail.gmail.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
To: Tim Murray <timmurray@google.com>
Cc: Sultan Alsawaf <sultan@kerneltoast.com>, Michal Hocko <mhocko@kernel.org>, 
	Suren Baghdasaryan <surenb@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	=?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, 
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-drivers <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000019, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 7:43 PM Tim Murray <timmurray@google.com> wrote:
>
> On Tue, Mar 12, 2019 at 10:45 AM Sultan Alsawaf <sultan@kerneltoast.com> wrote:
> >
> > On Tue, Mar 12, 2019 at 10:17:43AM -0700, Tim Murray wrote:
> > > Knowing whether a SIGKILL'd process has finished reclaiming is as far
> > > as I know not possible without something like procfds. That's where
> > > the 100ms timeout in lmkd comes in. lowmemorykiller and lmkd both
> > > attempt to wait up to 100ms for reclaim to finish by checking for the
> > > continued existence of the thread that received the SIGKILL, but this
> > > really means that they wait up to 100ms for the _thread_ to finish,
> > > which doesn't tell you anything about the memory used by that process.
> > > If those threads terminate early and lowmemorykiller/lmkd get a signal
> > > to kill again, then there may be two processes competing for CPU time
> > > to reclaim memory. That doesn't reclaim any faster and may be an
> > > unnecessary kill.
> > > ...
> > > - offer a way to wait for process termination so lmkd can tell when
> > > reclaim has finished and know when killing another process is
> > > appropriate
> >
> > Should be pretty easy with something like this:
>
> Yeah, that's in the spirit of what I was suggesting, but there are lot
> of edge cases around how to get that data out efficiently and PID
> reuse (it's a real issue--often the Android apps that are causing
> memory pressure are also constantly creating/destroying threads).
>
> I believe procfds or a similar mechanism will be a good solution to this.

Fwiw, I am working on this and have send a PR for inclusion in 5.1:
https://lore.kernel.org/lkml/20190312135245.27591-1-christian@brauner.io/
There's also a tree to track this work.

Christian

