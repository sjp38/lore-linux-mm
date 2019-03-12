Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A19D7C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 00:08:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E6112075C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 00:08:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="A0yHjNKx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E6112075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BFCD8E0003; Mon, 11 Mar 2019 20:08:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86DB28E0002; Mon, 11 Mar 2019 20:08:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75C8C8E0003; Mon, 11 Mar 2019 20:08:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0A90D8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 20:08:04 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id u138so169982lja.23
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 17:08:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Qt694sGi2lwRRCAVHkTT7ndj+scdvDKwGl7sZfr8K8k=;
        b=cGLFGT5uSoZ0yWEYYACxxoJUwU43jl4BYaoqkxstah2Us+69zfF083TGAVwd5USOWQ
         o9QyB7bOTwSmKvw2Ox8Ydl8YQkUM3cs2COeijZwEzOPYxoGDT3QoVFfClpEPEmtaFg+c
         aKD08TiH1Lf8zu4UzoOeuMtUFl/i4FTNMNSkPBh6k0ki42yocdNUpcNLqzedwxEa613K
         1h4DF60ovoJ5jJaDPvrqOKWexj0EPHoXudWiUHYRiWgwm34FIGoOCZFjBulilPcwQQ/0
         CwMFsBL1R3Un9u5fuJ+R9y0SbUO3jPSp+qPAt9Ts0bsrlxrcCyPDrv7qiZMI15GS4F7G
         xXmw==
X-Gm-Message-State: APjAAAUmj/sQBppxNfnk3eTC75UTzjWjcGXyhORGlOM6UxmoU2bJiMwT
	v84hS1eaIzmr66oURXoNK/nXmOn0fI10S/AomO8sCUbxHoZTYXbJIRUvBMosqg0ooRBoPfOp9a2
	ZfnyNSi4tD/A3YXAELoof5KbtfvmvpkbDdiq++IJ/NUkTSCxfRnp1P09dy5px6AB/FFwtfPQowy
	MwtbaWYaekOt6fEpUwpbeznODXiotEF8OYCCZNIBR6eaFhNT7NExGXGsumCQU9lilNQga/5K7/V
	j9dVIxGGjv3SHMu+TVC6ygpFVcgEcIg5CFukZtdsgYLgPOnsBg5lmMAB9zaF3sOBrIApUo1QNLc
	AK3mh9KhZXVAen8rZ/E4FtCResu5sIbrK5HuybpwY0cHJsPEp2tTi3FMkgHN4u02GOYKAclz977
	Q
X-Received: by 2002:a2e:9793:: with SMTP id y19mr17502642lji.194.1552349283130;
        Mon, 11 Mar 2019 17:08:03 -0700 (PDT)
X-Received: by 2002:a2e:9793:: with SMTP id y19mr17502612lji.194.1552349281875;
        Mon, 11 Mar 2019 17:08:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552349281; cv=none;
        d=google.com; s=arc-20160816;
        b=ON7iCvxyX4NBS3qquzVzEeKpru1S+uq3vnf5lNkMUHCNJVf76W6Y0RXnaY+N3ZYJY/
         cD02nER/hgRA2ZNCyyqC+ySkhVVZtpnBS4QWV9sFZ+XkFhml8Vevp4sOX/873lUFjlR7
         uQFn8dTlgdGIPnNDvZ0zgtVDuiVrU1W5u7FsvLqR5Ps2Hjolsh/tCAbvLMp8DUf3Xip0
         epVidZ6oZBidINnf9t8TtlS3CBSzzZeEgb6lN2PAateax496zOGPjoQ+MQS08B0UkjoO
         gmEB+6F7YVEOAhwNAuQaJbQNgtLPSpVGHAhDHqWysnXxhDUaqXlL/aTg3j0yeZhfobhc
         0Dwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Qt694sGi2lwRRCAVHkTT7ndj+scdvDKwGl7sZfr8K8k=;
        b=rakxXTqG19y4aGKzFSvneg8TeyPjRLpWsvPPIWhGfrOwSL85ItEqWB2u6+es/vjnDf
         eG7YAvIjiGWZCFEjRxWzmfX/MM5zMgSySx5gav+I7WXz+M74PbMtDhCe50Y9tArEq6Dc
         jdDmNVhprNRnZuPKNRvTCCX3k+2hIuoWeeZBiTsyeEavpAxSbzXjc8h/+m5LYBW5FF/C
         0VC9USTV/1IAoauUWp0x/3AdE1bPG61d97mlsvHZZnb4Z9iGs0RLLbMlnfBSGYpZrD5q
         exZLSHIyPuQwvNNORXpzXd5b+pQ6r1DQy/vsU+UK2Ja0lJ4qWVkDv7Mgo8/gPpeaJFOF
         /ZWA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=A0yHjNKx;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q190sor3700376ljb.7.2019.03.11.17.08.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 17:08:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=A0yHjNKx;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Qt694sGi2lwRRCAVHkTT7ndj+scdvDKwGl7sZfr8K8k=;
        b=A0yHjNKx5WvptfvDAlJCIScPZv5yWQVdV6SuSraSXLmHtTV6Ax0AesK3ins9D80g60
         Ku3kCS5faTcIuBqylJyRTEgWvdj0jF1oK1H1QNGjebEf0GRRcM7bohsnDyUdK4KpY0dr
         qNth7eZOZNiQyNe0TsSFjfOMEJDmo08bqpyEg=
X-Google-Smtp-Source: APXvYqyntRadZZXMYs7qXXkTpMTA/7XbGhJUdLWg/pjzXKcoG7UdfKLInvScAI+0Hdc7Xu0Er+at9g==
X-Received: by 2002:a2e:8589:: with SMTP id b9mr18116660lji.56.1552349280455;
        Mon, 11 Mar 2019 17:08:00 -0700 (PDT)
Received: from mail-lj1-f181.google.com (mail-lj1-f181.google.com. [209.85.208.181])
        by smtp.gmail.com with ESMTPSA id z4sm1124622ljz.43.2019.03.11.17.07.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 17:07:59 -0700 (PDT)
Received: by mail-lj1-f181.google.com with SMTP id v10so703629lji.3
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 17:07:59 -0700 (PDT)
X-Received: by 2002:a2e:8018:: with SMTP id j24mr17374435ljg.118.1552349279030;
 Mon, 11 Mar 2019 17:07:59 -0700 (PDT)
MIME-Version: 1.0
References: <CAPcyv4he0q_FdqqiXarp0bXjcggs8QZX8Od560E2iFxzCU3Qag@mail.gmail.com>
 <CAHk-=wjvmwD_0=CRQtNs5RBh8oJwrriXDn+XNWOU=wk8OyQ5ew@mail.gmail.com>
 <CAPcyv4hafLUr2rKdLG+3SHXyWaa0d_2g8AKKZRf2mKPW+3DUSA@mail.gmail.com>
 <CAHk-=wiTM93XKaFqUOR7q7133wvzNS8Kj777EZ9E8S99NbZhAA@mail.gmail.com> <CAPcyv4hMZMuSEtUkKqL067f4cWPGivzn9mCtv3gZsJG2qUOYvg@mail.gmail.com>
In-Reply-To: <CAPcyv4hMZMuSEtUkKqL067f4cWPGivzn9mCtv3gZsJG2qUOYvg@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 11 Mar 2019 17:07:43 -0700
X-Gmail-Original-Message-ID: <CAHk-=wgnJd_qY1wGc0KcoGrNz3Mp9-8mQFMDLoTXvEMVtAxyZQ@mail.gmail.com>
Message-ID: <CAHk-=wgnJd_qY1wGc0KcoGrNz3Mp9-8mQFMDLoTXvEMVtAxyZQ@mail.gmail.com>
Subject: Re: [GIT PULL] device-dax for 5.1: PMEM as RAM
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, 
	"Luck, Tony" <tony.luck@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 8:37 AM Dan Williams <dan.j.williams@intel.com> wrote:
>
> Another feature the userspace tooling can support for the PMEM as RAM
> case is the ability to complete an Address Range Scrub of the range
> before it is added to the core-mm. I.e at least ensure that previously
> encountered poison is eliminated.

Ok, so this at least makes sense as an argument to me.

In the "PMEM as filesystem" part, the errors have long-term history,
while in "PMEM as RAM" the memory may be physically the same thing,
but it doesn't have the history and as such may not be prone to
long-term errors the same way.

So that validly argues that yes, when used as RAM, the likelihood for
errors is much lower because they don't accumulate the same way.

> The driver can also publish an
> attribute to indicate when rep; mov is recoverable, and gate the
> hotplug policy on the result. In my opinion a positive indicator of
> the cpu's ability to recover rep; mov exceptions is a gap that needs
> addressing.

Is there some way to say "don't raise MC for this region"? Or at least
limit it to a nonfatal one?

                 Linus

