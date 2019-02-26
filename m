Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C551CC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 20:35:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4499321873
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 20:35:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=rath.org header.i=@rath.org header.b="RYg2VuhG";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="0ZychgeN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4499321873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=rath.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99BA18E0003; Tue, 26 Feb 2019 15:35:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 948EC8E0001; Tue, 26 Feb 2019 15:35:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 812BC8E0003; Tue, 26 Feb 2019 15:35:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5440F8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 15:35:55 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id f70so11323792qke.8
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 12:35:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:subject
         :references:date:in-reply-to:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=SH3OtmlQYztY1hVcAwbfBht4gbItJffosAmmOmWlCAc=;
        b=so47hR1c2IsxowFt4VuTO7t0TG8eyyrbsyOQkadNhr2uMaEWSEzOrzC/sXs4jtoNRP
         GGBS6C72lLVbNqSAf777FdonnlYxVPCvvaktdbgCeYhqzH3Mu7M4+tDRrrsD44r0kzjx
         PbaQ1eddOLUzhoRgG8Le7m9c5ftT7PkesDJiBakTo2jjAiPEaaXje/uprMbTv07TB3aE
         VTrUs8ssjEyP504n2kpD3yIYniLk6eNtYmy/7zPqbcpAFrwxSVnMekaG8sTY5RLflbyY
         35vKMUalepAyNG5XraTKLBpoHpIzsb3KBkd20k2TzCN5oHlIC61sLhEK1Se+sHPdRJUE
         jAbg==
X-Gm-Message-State: AHQUAub7ibp+bExAk5JyFikIT5V2nWJlTo6TB6kXC3jV/TcJs3shZIkR
	QBvhqyrdEtUjF49tVzoQJkbzoYSPpnCEt2jfjJNy0g1Epdsv67qqGkAQpeFyTLtc4AiZh4vImCB
	O4CLROozs38itjoctHptZbOqEY1EDDayjtkPx7vJjQgWh99f9nFlET8jdcE4W+f5UPw==
X-Received: by 2002:a37:4a4d:: with SMTP id x74mr18412431qka.61.1551213355032;
        Tue, 26 Feb 2019 12:35:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IayNUCpYaV/TPUqfmXCGj2UHayBPqZo3e924JV7bmpgz81AP1OinDVRMiqTTCNQvwu6/Cdq
X-Received: by 2002:a37:4a4d:: with SMTP id x74mr18412392qka.61.1551213354106;
        Tue, 26 Feb 2019 12:35:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551213354; cv=none;
        d=google.com; s=arc-20160816;
        b=SXGRAiWOJFwQob4TyKXsrcktOXQM2fMbF9xDqI0jEgfvDOIthLUzW1jDsZn9IfutXv
         DkX90oOYP78P/ymWx/HQja+xmsyeewlwNgF3oDKxE6Xu6DNHcjJyO02leAT+uE2BBA2j
         STE+jnN5AG6wbZuMyOJtjeuGvFeE77jRawaDL43Vom7ZztbHeLH7q/CTZQcorCOyOuXn
         wiw/ASANpv+sRTE4VF0IF3qz9ItWf4mgsFkxsa/mZipN6qdL2kry7dE58sTgEZsjXIp8
         YpQzsPzGI8YJCGvu60teUhWKXM6DmCk1z4TK8MB4kKJotyQQ0yRSFskLEFbs0TPJw4V6
         jc7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id
         :in-reply-to:date:references:subject:to:from:dkim-signature
         :dkim-signature;
        bh=SH3OtmlQYztY1hVcAwbfBht4gbItJffosAmmOmWlCAc=;
        b=tsFe9D2M+aSbWVpIW/0ziXh5LS2iSCrhD6HApydl3p6c/QwGn9OGGgwTe8137yFUCE
         yYxI/EjRTs/r7kbpgWM5nYJXNr5VzqhurJWvfkzPJYG04RKmVzmE3U3snZ0FG1T9tyUi
         pcZc1yfe3cBC+X2dyvI0ogMHF26pmVrcokLS8dfo8DklugGSQQkvJkRgys0B/Y+AinZV
         K3vP0s46Q+l1uCqiLWOjk3VqmhIlJJh5fhlFH9KETll8+/6U18zVFQs42BhouYDGHeSB
         tcwDFNa63jUA35DCYMj0OyaBEGGWhTEDO2glju0AnIv/lAmUj81SvklSdrGTF/Tyvakq
         ryOA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@rath.org header.s=fm1 header.b=RYg2VuhG;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=0ZychgeN;
       spf=pass (google.com: domain of nikolaus@rath.org designates 66.111.4.26 as permitted sender) smtp.mailfrom=Nikolaus@rath.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id z31si79328qtj.27.2019.02.26.12.35.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 12:35:53 -0800 (PST)
Received-SPF: pass (google.com: domain of nikolaus@rath.org designates 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@rath.org header.s=fm1 header.b=RYg2VuhG;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=0ZychgeN;
       spf=pass (google.com: domain of nikolaus@rath.org designates 66.111.4.26 as permitted sender) smtp.mailfrom=Nikolaus@rath.org
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id AA6432211F;
	Tue, 26 Feb 2019 15:35:53 -0500 (EST)
Received: from mailfrontend2 ([10.202.2.163])
  by compute1.internal (MEProxy); Tue, 26 Feb 2019 15:35:53 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=rath.org; h=from
	:to:subject:references:date:in-reply-to:message-id:mime-version
	:content-type:content-transfer-encoding; s=fm1; bh=SH3OtmlQYztY1
	hVcAwbfBht4gbItJffosAmmOmWlCAc=; b=RYg2VuhGTo7oZkqS1+m5RH3zpvemy
	v16Jh+7/3yfapPeDtXjERLZlNZK6tljjWRw6eQ7YjxzpAFhB+xU5Kx2j8KWmHqbA
	sQ8LVQig2HRGEmQgWLImVDVz1cqDg3M4+10x71jSCkExoxinC53nQljVzQ2SK9z1
	ip8wCHHcGDcq8T06Jmp4TaVaKqbu5ZmU/BQ2nZQ6XdirNLYV0qZ/0MS+MY7FVf0A
	gc+qMvLeUfX92Wuv9TtMueA7Jw/F1FZn1raPvWvxA/kTdNKNlEFPkWluTvQxQrYe
	6HZtsR4/+tM+X7jA8oF/a+VdJky99FgRtdc/ungAHYXddZXl+uOWeQOLQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=content-transfer-encoding:content-type
	:date:from:in-reply-to:message-id:mime-version:references
	:subject:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender
	:x-sasl-enc; s=fm2; bh=SH3OtmlQYztY1hVcAwbfBht4gbItJffosAmmOmWlC
	Ac=; b=0ZychgeNSkl/NgvqUu2ZGsDAbvyz1FsUAlzBS+qYqOOu6okVISa7tp1eg
	XeqK9Ka56SNUNBBZJR/eEaQUDnVQyabpT9obMzUfCmCrgpA6wiCT3yxX2Cx2U0ZS
	UspGjPzfzayZFNyze+F2IVFYlR/XgEEEjG4UyeZ4lPIgnqm/8wk+iqKFkjGlmYtE
	ILA2iIPMfF8u1usRXCMYrSZ8GdZ9leoNzzZAwjjxDaFhKO9RHziIA2y/HzumYvl1
	x8WJMUM1DePn6ZI4M7l5YGr/f/b/aIwd/x8cqvyLrBLZaSpStR4Jb4Frz+aKA55a
	IvXEDNnRnrtzHLNpzFA+Clh3rf/FQ==
X-ME-Sender: <xms:KKN1XL4AY4tV0Ik10PmsUh5lTC2xLu1bEJColSeXJbS5m5pXq9wYYg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrudelgddugedvucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    cujfgurhephffvufhfffgjkfgfgggtgfesthhqtddttderjeenucfhrhhomheppfhikhho
    lhgruhhsucftrghthhcuoefpihhkohhlrghushesrhgrthhhrdhorhhgqeenucffohhmrg
    hinhepshhouhhrtggvfhhorhhgvgdrnhgvthenucfkphepudekhedrfedrleegrdduleeg
    necurfgrrhgrmhepmhgrihhlfhhrohhmpefpihhkohhlrghushesrhgrthhhrdhorhhgne
    cuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:KaN1XFL6HmBvgms-kUsulqGznhOtSiwz7QeRwbt6RdCFolrJAlwp3w>
    <xmx:KaN1XNctWWPyOI8JJfmf_VtoeqIHOD4dquX5Cec7YzZirrhXVCIfhw>
    <xmx:KaN1XAe4Wi-ofCKUcV398YLEMaCJxAHz-zPIw47RLy7siguJsiJnlw>
    <xmx:KaN1XMC9eu5VXikVBNc3bExvCawMwVXGjOxcDkIqVkHsVdcUEzbfOw>
Received: from ebox.rath.org (ebox.rath.org [185.3.94.194])
	by mail.messagingengine.com (Postfix) with ESMTPA id 6A24310328;
	Tue, 26 Feb 2019 15:35:52 -0500 (EST)
Received: from vostro.rath.org (vostro [192.168.12.4])
	by ebox.rath.org (Postfix) with ESMTPS id 4D6C250;
	Tue, 26 Feb 2019 20:35:51 +0000 (UTC)
Received: by vostro.rath.org (Postfix, from userid 1000)
	id 0EFDAE00C3; Tue, 26 Feb 2019 20:35:50 +0000 (GMT)
From: Nikolaus Rath <Nikolaus@rath.org>
To: Miklos Szeredi <miklos@szeredi.hu>, linux-mm@kvack.org
Subject: Re: [fuse-devel] fuse: trying to steal weird page
References: <87o998m0a7.fsf@vostro.rath.org>
	<CAJfpegtQic0v+9G7ODXEzgUPAGOz+3Ay28uxqbafZGMJdqL-zQ@mail.gmail.com>
	<87ef9omb5f.fsf@vostro.rath.org>
	<CAJfpegu_qxcaQToDpSmcW_ncLb_mBX6f75RTEn6zbsihqcg=Rw@mail.gmail.com>
	<87ef9nighv.fsf@thinkpad.rath.org>
	<CAJfpegtiXDgSBWN8MRubpAdJFxy95X21nO_yycCZhpvKLVePRA@mail.gmail.com>
	<87zhs7fbkg.fsf@thinkpad.rath.org> <8736ovcn9q.fsf@vostro.rath.org>
	<CAJfpegvjntcpwDYf3z_3Z1D5Aq=isB3ByP3_QSoG6zx-sxB84w@mail.gmail.com>
	<877ee4vgr4.fsf@vostro.rath.org> <878sy3h7gr.fsf@vostro.rath.org>
	<CAJfpeguCJnGrzCtHREq9d5uV-=g9JBmrX_c===giZB7FxWCcgw@mail.gmail.com>
	<CAJfpegu-QU-A0HORYjcrx3fM5FKGUop0x6k10A526ZV=p0CEuw@mail.gmail.com>
Date: Tue, 26 Feb 2019 20:35:50 +0000
In-Reply-To: <CAJfpegu-QU-A0HORYjcrx3fM5FKGUop0x6k10A526ZV=p0CEuw@mail.gmail.com>
	(Miklos Szeredi's message of "Tue, 26 Feb 2019 14:30:01 +0100")
Message-ID: <87bm2ymgnt.fsf@vostro.rath.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/25.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[ Moving fuse-devel and linux-fsdevel to Bcc ]

Hello linux-mm people,

I am posting this here as advised by Miklos (see below). In short, I
have a workload that reliably produces kernel messages of the form:

[ 2562.773181] fuse: trying to steal weird page
[ 2562.773187] page=3D<something> index=3D<something> flags=3D17ffffc00000a=
d, count=3D1, mapcount=3D0, mapping=3D (null)

What are the implications of this message? Is something activelly going
wrong (aka do I need to worry about data integrity)?

Is there something I can do to help debugging (and hopefully fixing)
this?

This is with kernel 4.18 (from Ubuntu cosmic).

Best,
-Nikolaus


On Feb 26 2019, Miklos Szeredi <miklos@szeredi.hu> wrote:
> On Tue, Feb 26, 2019 at 1:57 PM Miklos Szeredi <miklos@szeredi.hu> wrote:
>>
>> On Mon, Feb 25, 2019 at 10:41 PM Nikolaus Rath <Nikolaus@rath.org> wrote:
>> >
>> > On Feb 12 2019, Nikolaus Rath <Nikolaus@rath.org> wrote:
>> > > On Feb 12 2019, Miklos Szeredi <miklos@szeredi.hu> wrote:
>> > >> On Sun, Feb 10, 2019 at 11:05 PM Nikolaus Rath <Nikolaus@rath.org> =
wrote:
>> > >>
>> > >>> Bad news. I can now reliably reproduce the issue again.
>> > >>
>> > >> A reliable reproducer is always good news.   Are the messages exact=
ly
>> > >> the same as last time (value of flags, etc)?
>> > >
>> > > The flags, count, mapcount and mapping values are always the same. T=
he
>> > > page and index is varying. So the general format is:
>> > >
>> > > [ 2562.773181] fuse: trying to steal weird page
>> > > [ 2562.773187] page=3D<something> index=3D<something>
>> > > flags=3D17ffffc00000ad, count=3D1, mapcount=3D0, mapping=3D (null)
>> >
>> > Is there anything else I can do to help debugging this?
>>
>> Could you please try the attached patch?
>
> Looking more, it's very unlikely to help.  remove_mapping() should
> already ensure that the page count is 1.
>
> I think this bug report needs to be forwarded to the
> <linux-mm@kvack.org> mailing list as this appears to be  a race
> somewhere in the memory management subsystem and fuse is only making
> it visible due to its sanity checking in the page stealing code.
>
> Thanks,
> Miklos
>
>
> --=20
> fuse-devel mailing list
> To unsubscribe or subscribe, visit https://lists.sourceforge.net/lists/li=
stinfo/fuse-devel


--=20
GPG Fingerprint: ED31 791B 2C5C 1613 AF38 8B8A D113 FCAC 3C4E 599F

             =C2=BBTime flies like an arrow, fruit flies like a Banana.=C2=
=AB

