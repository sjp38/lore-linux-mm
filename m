Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1281BC10F12
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 09:00:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B66C621773
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 08:59:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="2gcdtSWB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B66C621773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6600E6B000A; Wed, 17 Apr 2019 04:59:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 635686B000C; Wed, 17 Apr 2019 04:59:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 550426B000D; Wed, 17 Apr 2019 04:59:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1C0DE6B000A
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 04:59:59 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e128so15875906pfc.22
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 01:59:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=KYJa/ajm1M4cHXbvRCvZ6z3YRiQWwmCaRi3R4Fo73Q0=;
        b=PQQ/ZtLX3DtQvklZQqmJkg1wqqZ4EjvBOZVT6PoXSr74ATN0zFPSg0J94vrb5mpQjl
         M3r1eZxLcd/PmtMAmhuXxVBizdqk5VYd1a+OhbmO68RHzxyUkBcxoaHvgYpVaWjwC2g+
         Lt6KSLNJw1mwZrFT8avdHrf1HXUmPLfz5xCkH0uqnyyKJ6vQl463yu69ixK4xkKullDp
         fq+xJTKNBRc7Zjl1lNVS4hbOuYuyG+9fcNzSWgOkK60C+2CQTlMQsKtgEzY21YwpOyNp
         1aSAFcB7rIzalJ6fy2/3n6NUcb32lyoLS7HoDHJbq+64J4NZN8Bw2XFb8P0gQL/xt84Q
         wGMA==
X-Gm-Message-State: APjAAAUbMN4aH+orGgIS1+qhTuNHK53lP/hxH2DHt1FDNpzYKr1Exa1m
	W18N6FxZNXBusNWTOKiop5S1BcnxanAgr/Qdfux3ha5boLoH8cF1YgdFsXb1dslB+RllBJoEOq7
	Z6wzRvxkm8/BXEmcv0rDbPnL+/oU3JiSRph3CAvGee2LQfG0PEiuCSOINIW+RTFnx9w==
X-Received: by 2002:a63:6e0e:: with SMTP id j14mr80457315pgc.203.1555491598671;
        Wed, 17 Apr 2019 01:59:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1yUHvzuoSHPtaec3ajwI4RC+n+pwxYRzHCQMbbIOe9rUn29IcuF7SufbfJpnOuZmzjoFF
X-Received: by 2002:a63:6e0e:: with SMTP id j14mr80457269pgc.203.1555491597888;
        Wed, 17 Apr 2019 01:59:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555491597; cv=none;
        d=google.com; s=arc-20160816;
        b=oag0qa1yyU8mBO1sK+cFljBV89x8/F94ArcEVgvsGKBQQQjS5fBOy0g7g3OS6kfM6H
         1vCi4g92XpRJrb0fiDbepC1ZvVOFv9isi0+BXRYrL4C3QyRNaP/gT65iWyvI0jFJKIlM
         xww+7mJdNt85q7ezvKTOsIQAhbrV0/hD4x7CRDmsLih0t841m5Cpomx8hS32zAp8t5Hy
         E6XWt0aOThyAAt78yvWbd8nwgs7W8sKyiMHBD1cjjfvIHi5Vs1lYHjWz/tEDCBWA10jx
         QOcI0UWrKWxMF5iuWLwpFk1ul/vKt13IVi41t5BXW8tcnx2FItkhxeNdBdrzwuneGHwv
         5lFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=KYJa/ajm1M4cHXbvRCvZ6z3YRiQWwmCaRi3R4Fo73Q0=;
        b=yyYYLrsd8dlnmTAfUeDT5TER9Wl5ITqksy6X7IiLZveX/cJ8SuIH9P5U7AcL10f2AU
         jAES1Ooz6SurOxcegGwLCGtXrjDBjDlgNNTpn30E2qZBMthmj0w3yevH6ip2Tax+NOJh
         gHi0k2ZdMX9NGXr0YnM3PrOT597RHqMUxe4z23pOLYppYNKiUStBetYOBcWW1/lbSyb1
         qT88B3+TWwwi7w1x1cixQsA08F2+c+WSFCi5vZfjjfNWdJKAyynOs7+qAt8BEwshc+jo
         W7bchazJLsyJ4GTeaktXvhnwGwf0VcE+TfKC85CEdx49p2/Kb4fzHJmAX6jDeumdp2B6
         OOcA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=2gcdtSWB;
       spf=pass (google.com: domain of jeyu@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jeyu@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h20si45343403pgn.69.2019.04.17.01.59.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 01:59:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of jeyu@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=2gcdtSWB;
       spf=pass (google.com: domain of jeyu@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jeyu@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from linux-8ccs (charybdis-ext.suse.de [195.135.221.2])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6311A20693;
	Wed, 17 Apr 2019 08:59:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1555491597;
	bh=KYJa/ajm1M4cHXbvRCvZ6z3YRiQWwmCaRi3R4Fo73Q0=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=2gcdtSWBW6c8EjUfJwq3kxZZNNm9kdwUO5/VnRoZgb6vO5E3vGpgZlivBfQPKNfnM
	 MYZNS8xgAvLcVTfYlQ3jb3URIzqRN51ovm2OjA9pdwIxrC5MHPJ6Ru40n0FSBDot/a
	 utakIXj0oe7kL98FiBG9FmlynOl7FPZNd8U6v49A=
Date: Wed, 17 Apr 2019 10:59:52 +0200
From: Jessica Yu <jeyu@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tri Vo <trong@android.com>, Nick Desaulniers <ndesaulniers@google.com>,
	Greg Hackmann <ghackmann@android.com>, linux-mm@kvack.org,
	kbuild-all@01.org, Randy Dunlap <rdunlap@infradead.org>,
	kbuild test robot <lkp@intel.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Petri Gynther <pgynther@google.com>, willy@infradead.org,
	Peter Oberparleiter <oberpar@linux.ibm.com>
Subject: Re: [PATCH v2] module: add stubs for within_module functions
Message-ID: <20190417085952.GB17099@linux-8ccs>
References: <20190415142229.GA14330@linux-8ccs>
 <20190415181833.101222-1-trong@android.com>
 <20190416152144.GA1419@linux-8ccs>
 <CANA+-vDxLy7A7aEDsHS4y7ujwN5atzkGrVwSvDs-U3Oa_5oLFg@mail.gmail.com>
 <CANA+-vAvLUFPhfXj_CxkV8Fgv+zmqvu=MxwtwFTbr5Nrn68E9g@mail.gmail.com>
 <20190416143813.4bac4f106930f6686164c11b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190416143813.4bac4f106930f6686164c11b@linux-foundation.org>
X-OS: Linux linux-8ccs 5.1.0-rc1-lp150.12.28-default+ x86_64
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

+++ Andrew Morton [16/04/19 14:38 -0700]:
>On Tue, 16 Apr 2019 11:56:21 -0700 Tri Vo <trong@android.com> wrote:
>
>> On Tue, Apr 16, 2019 at 10:55 AM Tri Vo <trong@android.com> wrote:
>> >
>> > On Tue, Apr 16, 2019 at 8:21 AM Jessica Yu <jeyu@kernel.org> wrote:
>> > >
>> > > +++ Tri Vo [15/04/19 11:18 -0700]:
>> > > >Provide stubs for within_module_core(), within_module_init(), and
>> > > >within_module() to prevent build errors when !CONFIG_MODULES.
>> > > >
>> > > >v2:
>> > > >- Generalized commit message, as per Jessica.
>> > > >- Stubs for within_module_core() and within_module_init(), as per Nick.
>> > > >
>> > > >Suggested-by: Matthew Wilcox <willy@infradead.org>
>> > > >Reported-by: Randy Dunlap <rdunlap@infradead.org>
>> > > >Reported-by: kbuild test robot <lkp@intel.com>
>> > > >Link: https://marc.info/?l=linux-mm&m=155384681109231&w=2
>> > > >Signed-off-by: Tri Vo <trong@android.com>
>> > >
>> > > Applied, thanks!
>> >
>> > Thank you!
>>
>> Andrew,
>> this patch fixes 8c3d220cb6b5 ("gcov: clang support"). Could you
>> re-apply the gcov patch? Sorry, if it's a dumb question. I'm not
>> familiar with how cross-tree patches are handled in Linux.
>
>hm, I wonder what Jessica applied this patch to?

I applied the patch that supplies the missing within_module() stubs to
the modules-next branch (a link to the repo is available in
MAINTAINERS), it's landed in linux-next by now, and it should fix the
build error reported by the kbuild test bot.

Thanks,

Jessica

