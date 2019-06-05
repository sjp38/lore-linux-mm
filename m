Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B925C28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 12:39:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF0EC206BB
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 12:39:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF0EC206BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=units.it
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 302FE6B0005; Wed,  5 Jun 2019 08:39:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E1996B000A; Wed,  5 Jun 2019 08:39:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C9256B000D; Wed,  5 Jun 2019 08:39:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id CB8186B0005
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 08:39:25 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id 9so2225967ljv.14
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 05:39:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:from:cc
         :subject:in-reply-to:mime-version:content-id:date:message-id;
        bh=uRPW6eGphI7BrsEOvpQJFYHWUoy9Zh+W4tF3lvgZaXc=;
        b=gLZYymxdosdF6FReix1oVcAazOS0lu349ottruOH3c5tEH2yX2skcD2RotY4TjNM9d
         UBoj/7ZBaf2Haz8AFtNQFqaXaJ59J2o1MTeySJ4xswTIfSUxvk46nVViV6OphOF2hp42
         SETh/2jeWliDNAy1SKY8WZnK3TVOcUWhUHGzCtEL+rFXimT8HWlax9u/xqyv8QLCT8gW
         gq9u0Lw/fBVCc1+cvPIPZjGS836DGnydFSecfAPciS2ZAlWF/8pUyBs1d+Ttc/AZ+G5k
         fEqQaY3ELe7lsTBBibLAFGV4ZBiD/2TLhjyIZ3OKh45D3oafEySXT/GwJsPkYZv7I84t
         3BYA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) smtp.mailfrom=balducci@units.it
X-Gm-Message-State: APjAAAVLNzrLhT6OAegSddGlI5rrB4l7/MPFKt8kEVcvwmUV76XNYi+r
	V5SkVgGQPd/g5WPX4KhiKgHXYZsSOuJ3hklbOatR4Jt3q5k764XAsyZwb4GaSeAPgJvdh+S9WcK
	E+KfIv3Jkv1/HgJ84u2J8/o5I73ShMZkVkW88a/gwb/fGzrs9mOm7pt3zCCoGWZDt6w==
X-Received: by 2002:a2e:9a96:: with SMTP id p22mr3859198lji.57.1559738365081;
        Wed, 05 Jun 2019 05:39:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5kmKT4CjtOMz5yTAHa641k9dmRnATs2lT5b9v19sX6RNll1HQIS0mzDP1YaEK952tf7sn
X-Received: by 2002:a2e:9a96:: with SMTP id p22mr3859091lji.57.1559738363137;
        Wed, 05 Jun 2019 05:39:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559738363; cv=none;
        d=google.com; s=arc-20160816;
        b=JqqZYz+/R63mi/rJZ3vAthsvgJc2b8dT+XiNaJ4UgdSb+Y2bVhI2gc5+F1fDQF31N7
         620aRHtbv/kW74szXIbxW+pm2A+v130gUZ7d0u9POcdyP4ogBrb/WTJnHkY4iNZKHp2S
         OUDQC7gegIwFHYk9EkyyyINjsM4gb+Kj/Ma5HehH3lfxJmTVzeH4GGRDxVajP2RbRvPW
         x6QjtDxEVNbtRTc1ip3kruaXzWdQCn1jJ2j3SlmiNcpHQLmWa6D4RRhmVxhpDcoPoooT
         z7wwAwxKUAEPxnau8pQ+A4LLrfPTaTBVVuO7rU1S7nU6Ji+4HiYnnl6iV390M8qhlS65
         JtNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:content-id:mime-version:in-reply-to:subject:cc:from
         :to;
        bh=uRPW6eGphI7BrsEOvpQJFYHWUoy9Zh+W4tF3lvgZaXc=;
        b=wzfDtAlGLUFzpeiEl7ImKpyDQ3Q51s6L863Pg3i8VPa5cI44ftpmZuwQcS/tMV4lr2
         vHf21lceKP5s0QVMuiXBMC/TW4pPwDIkkMtfkCBjrhK+4gRWpX10jZ0yzwZqeXXcVisw
         wZJrCZ3ywRIzRPENImlgsLosEHuOHAGDSjY1vZlhZdd8GZDbAkDx747rW2wxcGp1aqBx
         GTyRd4lxlWFli3LagR90j31G+MzPkUQpVjFgi6dzqPmTMc4FJXGuRFikk3e9AFYpaPq9
         kDVsrHI8WMdrVZERxuK06Ccph7N+63MJvXR9z+0VoeeU63dMxYTdSGT0iuyRcMyeUqt6
         BUGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) smtp.mailfrom=balducci@units.it
Received: from dschgrazlin2.units.it (dschgrazlin2.univ.trieste.it. [140.105.55.81])
        by mx.google.com with ESMTP id h9si17486994lfm.29.2019.06.05.05.39.22
        for <linux-mm@kvack.org>;
        Wed, 05 Jun 2019 05:39:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) client-ip=140.105.55.81;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) smtp.mailfrom=balducci@units.it
Received: from dschgrazlin2.units.it (loopback [127.0.0.1])
	by dschgrazlin2.units.it (8.15.2/8.15.2) with ESMTP id x55CctMd011511;
	Wed, 5 Jun 2019 14:38:55 +0200
To: Mel Gorman <mgorman@techsingularity.net>
From: balducci@units.it
CC: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org,
        akpm@linux-foundation.org
Subject: Re: [Bug 203715] New: BUG: unable to handle kernel NULL pointer dereference under stress (possibly related to https://lkml.org/lkml/2019/5/24/292 ?)
In-reply-to: Your message of "Tue, 04 Jun 2019 12:05:10 +0100."
             <20190604110510.GA4626@techsingularity.net>
X-Mailer: MH-E 8.6+git; nmh 1.7.1; GNU Emacs 26.2
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <11509.1559738359.1@dschgrazlin2.units.it>
Date: Wed, 05 Jun 2019 14:38:55 +0200
Message-ID: <11510.1559738359@dschgrazlin2.units.it>
X-Greylist: inspected by milter-greylist-4.6.2 (dschgrazlin2.units.it [0.0.0.0]); Wed, 05 Jun 2019 14:38:55 +0200 (CEST) for IP:'127.0.0.1' DOMAIN:'loopback' HELO:'dschgrazlin2.units.it' FROM:'balducci@units.it' RCPT:''
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (dschgrazlin2.units.it [0.0.0.0]); Wed, 05 Jun 2019 14:38:55 +0200 (CEST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

hello

> Sorry, I was on holidays and only playing catchup now. Does this happen
> to trigger with 5.2-rc3? I ask because there were other fixes in there
> with stable cc'd that have not been picked up yet. They are a poor match
> for this particular bug but it would be nice to confirm.

I have built v5.2-rc3 from git (stable/linux-stable.git) and tested it
against firefox-67.0.1 build: no joy. 

I'm going to upload the kernel log and the config I used for v5.2-rc3
(there were a couple of new opts) to bugzilla, if that can help

thanks
ciao
-g

