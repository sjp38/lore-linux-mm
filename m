Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0510C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 16:04:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A01EA20855
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 16:04:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tEn3XtWe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A01EA20855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 298DC6B000D; Thu,  4 Apr 2019 12:04:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 223036B000E; Thu,  4 Apr 2019 12:04:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C2B96B0010; Thu,  4 Apr 2019 12:04:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id DBB826B000D
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 12:04:18 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id x12so2707135qtk.2
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 09:04:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=NVt5g98W3+zL+YOLzZe0kkeLDH/gD1BOQ/T34wUL2LQ=;
        b=mSCI1/rjTqyh2z7RASGoZeX1fi8+GDC6y85pzsYvb28sFwULEC3YNoKTtkDEFbzKhS
         bxc13DVBD9RXrfAXuNvyOdzR4g8Cy4UN3NRNfYXSNNvT61/IxtGPVoKgjpHpYAXJcMFX
         lnFJ/Yf7G2NKbNJCXEAG6XCfhW+6etWt/NM2uME4h3JTm9NybYBSwE//1imgR5FX032o
         U4MHVCqwHOgfMn8RIceYSuPKDRFwUN2qNxMsEXkfTJQDj5wIs+HbgJqlzEPYJfAlQhmY
         fJjbGhzgGAV9LWTsUQGUBEBB3XXefnXRn4PTGfe2l6GqN0+VFyM7oCI+edCRmdKg2b1h
         +3Pw==
X-Gm-Message-State: APjAAAU8PLvkzCTRkm9UzcTVKFxj+fZlIUj+yaek/q3vi4qeGNsacZ4N
	JoR2hgVU2UrFa3jC/fI5l+7VsTP016plbUUImb7lFx98JB7mVQ4JUiC66JtPYZTHfvUDBJFK0z/
	yPq1HQ/41Opr9YmIWEhthyXtIiU4D6ikb3jzskG2nNbVfytIun9f32bovEuNVwDjRtw==
X-Received: by 2002:a0c:9e68:: with SMTP id z40mr5454973qve.19.1554393858645;
        Thu, 04 Apr 2019 09:04:18 -0700 (PDT)
X-Received: by 2002:a0c:9e68:: with SMTP id z40mr5454819qve.19.1554393857315;
        Thu, 04 Apr 2019 09:04:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554393857; cv=none;
        d=google.com; s=arc-20160816;
        b=0t8UHTbFO0i+gHd90OIhggg7HWv4otC8Mot23cQbzADPKEf6yz3ylMq9R9cKqvOEN0
         0UJXxoM8ddrx4tRfBSgEoowL6r2JYBl09rETSacpAYjpKdedTl6wcCyhTOusAB8BnHTI
         Bfl/iaPeIhiX5o7K44kXt2jx84V3I5dbpKcMJP/QoKkEn9iy0EKJE6u5wmBX1X08oVRw
         qsHjWLt+7KI+hR4eOH2hCFev3jzQ9yWblhZncIOuJPjsF5HCDKvW6MQBtld5X8q0dKQG
         6st7+8u7ufCFw/k3j1cHFRBxQyHS6i/fA031MeheTpTwrH/BxbkeLtx8edPlO24tt1nb
         01PA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=NVt5g98W3+zL+YOLzZe0kkeLDH/gD1BOQ/T34wUL2LQ=;
        b=sdDoHR16DHrRm2fqCACCt5pLdBL2XjMK3GrTt3XJ5dHeldVOqedJVx9u6h3AwNOiQG
         Ap2qHghVzq4xKCS/+4Ow0DMFr7g1AgK9cmXB/WP1x6CR8Knjhc+EiTxDRVeqfY/Klo72
         H5smt8gmI3MO6tQCvKG1D5toPjEzALryuLGV4OXatL6QhksgUofwzzTe/ZZAwj6QkXQJ
         GHwbMnYNDT6iEz9/hzSBCtH3OIdUl7tC/9ZYQ8Bm0qd4MKLWW5KN6BqT6Mn5Ry0xnyFR
         ABSAjQY7yDl0NYC9EZjTJRXq3bwQkbd1JxMNTJJnlCRgc2wqusFqyW3WwDd7cG25zj7v
         wJSw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tEn3XtWe;
       spf=pass (google.com: domain of matheusfillipeag@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matheusfillipeag@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f6sor3043667qkd.41.2019.04.04.09.04.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Apr 2019 09:04:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of matheusfillipeag@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tEn3XtWe;
       spf=pass (google.com: domain of matheusfillipeag@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matheusfillipeag@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=NVt5g98W3+zL+YOLzZe0kkeLDH/gD1BOQ/T34wUL2LQ=;
        b=tEn3XtWe0A37rx+whdwqXjKvgGiCENoh6B1yypzZfoufjkrNLQcgQ6MKsFKhXZp1a6
         WNTOs18fLY6oUjXwjhUDEiPPK9m7EdlbRAOUhHWgsWqVajz2Fa2znjqv7TtdYQ8DYA3u
         69Q7C2DCwDYdLNMmxoHP3ETZc2TT5cD02hTkiOW2jGRp/h2HqSqSxyC0loaccmRtExc6
         +CSlnns9ECAA2WoXB+wYk5LTEpCBv5v11erGcb0n1qK9ThQ6vunwaVgTOhzoXgKcGIDg
         MG7xgYQyVVSFT1PUP7SJ+BbM5XEXjOlSZBXTiUJYpKrN922tn+YeftaCPhzvYMw30nWd
         x1hQ==
X-Google-Smtp-Source: APXvYqygBQO6Q6SMd1QtlcyVH0/WL5AjCi5BfxgkxlQtNdPluR7HtgGBQDWn+71q0cQaAwtSxr1pWw==
X-Received: by 2002:a05:620a:133b:: with SMTP id p27mr5429039qkj.173.1554393856668;
        Thu, 04 Apr 2019 09:04:16 -0700 (PDT)
Received: from [192.168.1.101] ([191.54.64.15])
        by smtp.gmail.com with ESMTPSA id x33sm12070151qth.7.2019.04.04.09.04.12
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 09:04:15 -0700 (PDT)
Subject: Re: [Bug 75101] New: [bisected] s2disk / hibernate blocks on "Saving
 506031 image data pages () ..."
To: Rainer Fiebig <jrf@mailbox.org>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>,
 "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
 Johannes Weiner <hannes@cmpxchg.org>, =?UTF-8?Q?Rodolfo_Garc=c3=ada_Pe?=
 =?UTF-8?B?w7FhcyAoa2l4KQ==?= <kix@kix.es>,
 Oliver Winker <oliverml1@oli1170.net>, bugzilla-daemon@bugzilla.kernel.org,
 linux-mm@kvack.org, Maxim Patlasov <mpatlasov@parallels.com>,
 Fengguang Wu <fengguang.wu@intel.com>, Tejun Heo <tj@kernel.org>,
 "Rafael J. Wysocki" <rjw@rjwysocki.net>, killian.de.volder@megasoft.be,
 Atilla Karaca <atillakaraca72@hotmail.com>
References: <20140505233358.GC19914@cmpxchg.org> <5368227D.7060302@intel.com>
 <20140612220200.GA25344@cmpxchg.org> <539A3CD7.6080100@intel.com>
 <20140613045557.GL2878@cmpxchg.org> <539F1B66.2020006@intel.com>
 <20190402162500.def729ec05e6e267bff8a5da@linux-foundation.org>
 <20190403093432.GD8836@quack2.suse.cz>
 <1ea9f923-4756-85b2-6092-6d9e94d576a1@mailbox.org>
 <CAFWuBvcS-8AFZ4KoimMrLPjFXGE8a48QnSqV3_gajJNWYZymGA@mail.gmail.com>
 <56c1efb7-142b-9ae3-7f59-852d739f6632@mailbox.org>
 <CAFWuBvfxS0S6me_pneXmNzKwObSRUOg08_7=YToAoBg53UtPKg@mail.gmail.com>
 <b44b1264-25ff-336c-9db5-59ab2adbddf3@mailbox.org>
From: matheus <matheusfillipeag@gmail.com>
Message-ID: <954f54bf-3ad4-290b-fc27-6998844f5a94@gmail.com>
Date: Thu, 4 Apr 2019 13:04:10 -0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <b44b1264-25ff-336c-9db5-59ab2adbddf3@mailbox.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


> So you got hibernate working now with pm-utils*and*  the prop. Nvidia
> drivers. That's good - although a bit contrary to what you said in
> Comment 29:
>
I was told so, long time ago struggling to get nvidia prop to resume 
from hibernation, I found out that uswsusp was better for it (googling 
or on irc), and it indeed worked better, or with less effort at least, 
back  then.  I made that comment thinking this was true but I just 
proved myself wrong...

> till puzzles me is that while others are having problems,
> suspend-utils/uswsusp work for me almost 100 % of the time, except for a
> few extreme test-cases in the past. You also said that it worked
> "flawlessly" for yo

Yes! It worked pretty good on version 18.04.1 of ubuntu with kernel 
4.15.0-42 and 41 using uswsusp. There was a long problem with nvidia 
props that wouldn't let the system resume, but this was fixed when I 
upgraded to the latest version of the 415 nvidia driver. I kept like one 
month just hibernating to switch to windows and coming back to the 
restored snapshot of linux.  You can check my apt history here: 
https://launchpadlibrarian.net/415602746/aptHistory.log. At the 
Start-Date: 2019-02-02 15:40:45, I'm 100% sure it was perfect. I am 100% 
sure that it wasn't already working anymore having the s2disk freeze 
issue at Start-Date: 2019-03-05 10:38:4.

uswsusp also worked fine on ubuntu 16.04, but I dont remember the kernel 
versions. Now I'm currently with the nvidia 418.56, ubuntu 18.04.2, 
kernel 4.18.0-17-generic and hibernation with pm-utils works. I haven't 
found any major problem with it besides failing to suspend to ram 
yesterday, which  I don't know if is related to it or not, but today I 
tested it after and before hibernation and seems to be ok.

> So I'm wondering whether used-up swap space might play a role in this
> matter, too. At least for the cases that I've seen on my system, I can't
> rule this out. And when I look at the screenshot you provided in Comment
> 27 (https://launchpadlibrarian.net/417327528/i915.jpg), sparse
> swap-space could have been a factor in that case as well. Because
> roughly 3.5 GB free swap-space doesn't seem much for a 16-GB-RAM box.

On my many tests with uswsusp and a 16gb swap partition and 16 gb of 
ram, I noticed that it would be less likely to fail when less than 
something about 2 gb of ram, like just after boot up, it would though 
after the 3rd or 4th followed hibernation cycle. If after the boot up I 
allocate more than that value if would be much more likely to happen 
like always on the 2nd attempt, and if more than around 6gb would fail 
on the first attempt.

Those aren't sure values, sometimes it failed regardless of ram usage, 
specially on my latest tests. also once it hibernated with more than 
11gb ram usage and failed on the second attempt. So this is all 
happening pretty randomly. What I described above is just most of the 
cases and maybe this is just random anyway.









