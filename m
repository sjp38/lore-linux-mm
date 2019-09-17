Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD233C4CEC9
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 07:25:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F43721E6F
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 07:25:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CYtpc7JB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F43721E6F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 195246B0006; Tue, 17 Sep 2019 03:25:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 145926B0008; Tue, 17 Sep 2019 03:25:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 033816B000A; Tue, 17 Sep 2019 03:24:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0011.hostedemail.com [216.40.44.11])
	by kanga.kvack.org (Postfix) with ESMTP id D13206B0006
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 03:24:59 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 69F732DFF
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 07:24:59 +0000 (UTC)
X-FDA: 75943575918.26.spoon58_e616b6b36f17
X-HE-Tag: spoon58_e616b6b36f17
X-Filterd-Recvd-Size: 7215
Received: from mail-lf1-f68.google.com (mail-lf1-f68.google.com [209.85.167.68])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 07:24:58 +0000 (UTC)
Received: by mail-lf1-f68.google.com with SMTP id r134so1959258lff.12
        for <linux-mm@kvack.org>; Tue, 17 Sep 2019 00:24:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Qwg6zM/jLzVfFWvAafz0P3l4DlIs73HFOS11i0AOm/E=;
        b=CYtpc7JBwVYZJkO5bu+hMw9nz74gAbzWv4jysLzN0tPty/ZkbNDatrXNIOvil+bvYV
         j+msbzNId38AXGZ0m6gDP9S2+djOAoZL56MwYXPN+HPtktitm41HS+C0WBppkYSRxMbL
         M4zi5Ayw2PKWtJMFWPkd02Ab74issxyifvYumCXUmh3sTMBO/dRunwk+dqk7FXWgiTux
         hBLy130UQolJiXY9TGrIE856omIdQsJXneExri7BgEkyOmfObAaYXKx6SW3qqsYqw8jv
         8LjNJWAfTNWelG3EOZXS/5FjQVSotgtne2NYjRYC2jEq584I0r7ejEedOPDpKP/XSG27
         mZ1w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=Qwg6zM/jLzVfFWvAafz0P3l4DlIs73HFOS11i0AOm/E=;
        b=HXYc76Kr2FkSZXSyF047a99gpF4UNRTJf3EKVh8HfmMyrqJCyn6IVTYx0EiS81vtXF
         1uWFU11r1Up1d9SD2BTBvTuU/k4/+0il/K2egtAc2NiWJ0W5UBBg7Wchxc0cdRDcO/30
         cJHlaz8ps+RGZkKuCFqnz0BuXlOwVawnOeMgBLXicHNf8et2brdRP3gDwD75HmEissfq
         lsZTY1jwgIn8Wdq1n5YhHx5TM9AsSs+SQLKACZQS1p4Vdr5PLTg0M/vNxV3NnRABGFuw
         3b7/2be9uwgvEy9uuCMl8NR0ugCDNzDDvnK89v2jJHvm7C4W+k4F1tQD2K4fHgluXo7r
         aqlg==
X-Gm-Message-State: APjAAAXLjtb4v5Rc4yQ0H4BvtA/8aRHnp5UnISaBjhWc+hYGIkekq4JZ
	mTddgCO9c1o+APH2BsaYIihuErZD38CS8q2FuRc=
X-Google-Smtp-Source: APXvYqy+NcmNXsIN+VRAJQK2Y/gl0meGEC5ot2nIdx79cDdmz8XlaRY4mVGgamAd4LU1uS5J7tPh6iLwbqL2MSAeoKc=
X-Received: by 2002:a19:f24d:: with SMTP id d13mr1241547lfk.127.1568705097080;
 Tue, 17 Sep 2019 00:24:57 -0700 (PDT)
MIME-Version: 1.0
References: <20190902094540.12786-1-janne.karhunen@gmail.com>
 <20190909213938.GA105935@gmail.com> <CAE=NcraXOhGcPHh3cPxfaNjFXtPyDdSFa9hSrUSPfpFUmsxyMA@mail.gmail.com>
 <20190915202433.GC1704@sol.localdomain> <CAE=NcrbaJD4CaUvg1tmNSSKjkG-EizNM7GUaztA0=fiUCo03Cg@mail.gmail.com>
 <20190917042334.GA1436@sol.localdomain>
In-Reply-To: <20190917042334.GA1436@sol.localdomain>
From: Janne Karhunen <janne.karhunen@gmail.com>
Date: Tue, 17 Sep 2019 10:24:45 +0300
Message-ID: <CAE=NcrYOEUU0yKT9HdB+HEKjsFKFUqnHP96_OnUrr=XxobD9Jg@mail.gmail.com>
Subject: Re: [PATCH 1/3] ima: keep the integrity state of open files up to date
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org, 
	Mimi Zohar <zohar@linux.ibm.com>, linux-mm@kvack.org, viro@zeniv.linux.org.uk, 
	Konsta Karsisto <konsta.karsisto@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.002837, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 17, 2019 at 7:23 AM Eric Biggers <ebiggers@kernel.org> wrote:

> > > Who will use it if it isn't 100% safe?
> >
> > I suppose anyone using mutable data with IMA appraise should, unless
> > they have a redundant power supply and a kernel that never crashes. In
> > a way this is like asking if the ima-appraise should be there for
> > mutable data at all. All this is doing is that it improves the crash
> > recovery reliability without taking anything away.
>
> Okay, so why would anyone use mutable data with IMA appraise if it corrupts your
> files by design, both with and without this patchset?

Now you are exaggerating heavily: it does not corrupt your files by
design. A crash in any security related system is supposed to be
pretty rare occurrence.


> > Anyway, I think I'm getting along with my understanding of the page
> > writeback slowly and the journal support will eventually be there at
> > least as an add-on patch for those that want to use it and really need
> > the last 0.n% reliability. Note that even without that patch you can
> > build ima-appraise based systems that are 99.999% reliable just by
>
> On what storage devices, workloads, and filesystems is this number for?

I reached 99.2% recovery rate with the AOSP without touching the
android on top by crashing the kernel with a test case while the
device was in use. 80% if I crash it while the device is in the
busiest write cycle (the first boot, I guess we would suck quite
royally if we never made past this point without dying).

99.95+% of course requires a high-availability system that probably
crashes once per year at best and recovers in seconds. In that case
this will recover it with pretty high odds, so reliability is not all
that much reduced from it's normal reliability statistics. So, the
ima-appraise for the mutable data could be in use even in a
high-availability system. 99% recovery probability for the crash that
occurs once per year would be OK; 0% would not be. I suppose it all
depends on your requirements.


> > having the patch we're discussing here. Without it you would be orders
> > of magnitude worse off. All we are doing is that we give it a fairly
> > good chance to recover instead of giving up without even trying.
> >
> > That said, I'm not sure the 100% crash recovery is ever guaranteed in
> > any Linux system. We just have to do what we can, no?
>
> Filesystems implement consistency mechanisms, e.g. journalling or copy-on-write,
> to recover from crashes by design.  This patchset doesn't implement or use any
> such mechanism, so it's not crash-safe.  It's not clear that it's even a step in
> the right direction, as no patches have been proposed for a correct solution so
> we can see what it actually involves.

Great, what would be the better alternative? I guess the suggestion
cannot be that 'don't use it' since the code is there?

As for the 'step to the right direction': before we could talk about
any of this journaling stuff we had to make sure that we have the
plumbing where the measurements are accurate. These patches do that
and the journaling is the next step. All the journaling add-on does
now is that it binds the page write and the xattr update into one
transaction, so both of those run as sub-transactions of one master.
Now, only when the master ends the data is moved out of the journal in
one bundle. All this is so ridiculously simple I doubt my own eyes,
but it seems to work fine apart from some slowdown on shutdown when
processes call sync() like there is no tomorrow. Nevertheless,
understanding the related code (the page writeback and the ext4) is
pretty nasty and there are lots of things I need to understand about
that still. The thing I'm currently trying to get my head around is
that whether or not it is possible that we have a measurement over a
page that was not eligible for the writeback. I'm also no ext4 expert
so all help in that regard is highly appreciated if this type of thing
is interesting to others.

Anyway, all this is good info. If this code is not needed upstream,
I'm happy to stop working with it and will maintain this for my use
only. Let me know,


--
Janne

