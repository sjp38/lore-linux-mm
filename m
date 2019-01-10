Return-Path: <SRS0=Jdrj=PS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE38DC43387
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 09:42:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9EAC8214C6
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 09:42:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XFQFj3p1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9EAC8214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 41A6B8E009F; Thu, 10 Jan 2019 04:42:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C9468E0038; Thu, 10 Jan 2019 04:42:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DEF48E009F; Thu, 10 Jan 2019 04:42:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 065CD8E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 04:42:28 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id m128so10424760itd.3
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 01:42:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=7M3wwWlrs4tEunRjESsdbGOWmA1PGb5ePkFyeLIYn0s=;
        b=K3RDYy6rVT1r7hN7lz2nlQV71snsC2t6ZnS0CqUyJhNCgHhd/MozuG8DFBUm/hkaIY
         VDiNus+4eT3HUEuiH1xoxAypnLW+jwC9B8y9WP4vTWB64MSL6ljPwynXKxOdL8XpYWHE
         3h06dQtJIogbe2FMhcLHTW3toqSQdtGZ8R0XXBMH7lb5jGJn7UjvU9bBAtGw1Visj0Lk
         V8pZQncxvap6j71q80d508OI3ME1zH+xrnwh5mneLpr68qD0lv3DG+ypYvVOm1ZnfOTm
         iNhs6zhyczUFNYV7VK6EXfZHTXwGR0jcLEwd8Du77uU+JijyAgdr+MbGlCVyNwststOn
         rqng==
X-Gm-Message-State: AJcUukc1Dn44/vo7HfwatdB3f+nXGg3hWmMKsylhjbX8gsGhwh/oBC9y
	ODvLKSMBzmdDksznR6tn8wLGnwFJEi6HplX/i1rhB92MFfrSV6GJspk0Lc490w5fZTFWgnkqwy/
	8ourkyWqgdlOt5hpcSTGEBWyVkVTw0SDzebmAIEU2+znwbF0SXNhhP1uFcV/E8Oofh9tGiCcUA6
	S36d6I1Sl18xBD2Z6ZmnECIjPujclH6tWrhmS+5FHnErbBWRNNMi9NMvywrhAqLtoq6mYINv4rs
	tgVdb8gvyJsgfS614rQ/7zP8Ay78SrMOEPMJIhOGIo2D0BNV0/tzpbJ1VEduDPUbnKRTqqn8LCE
	9VXgdZL4jkhA5Jx4d5VDlzwS1XYZSjv2fkxQySf6VttxfiWWHs7LgM0yEHci5Dy3vUDMlbPX7ik
	I
X-Received: by 2002:a24:e38f:: with SMTP id d137mr6199955ith.69.1547113347789;
        Thu, 10 Jan 2019 01:42:27 -0800 (PST)
X-Received: by 2002:a24:e38f:: with SMTP id d137mr6199938ith.69.1547113347044;
        Thu, 10 Jan 2019 01:42:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547113347; cv=none;
        d=google.com; s=arc-20160816;
        b=G3WTfBqnCJ+VZA+w+ThvGZbkJHmFhgoNcfAMzkoVTDg96i74B0Wehf+exopepdmZim
         gaw7nxb/zY81EYvFxM85740qekLmHfiSMGIwAmDZS3zSXFVngEW5TbUUIhi666rotb7G
         B5UbZDAhcs8OubsEkY/j/Rb+PNw72YM2kU1dCcX9RyWWvraIHwcRcBvPKfRLqMu7K+sG
         A+fsAEertxU/1aXCQA6UjhTOX3flbbLLHBQjIwdTjMBtgM8TEa6HZKc0DBQeHgiQML2e
         Kqwy39jO9I5c8mvaQfqKflLZoTJMePYs3mrl9dw6mjnNkPfw/lZKfHh2qSJ0aHXOz6yy
         jxGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=7M3wwWlrs4tEunRjESsdbGOWmA1PGb5ePkFyeLIYn0s=;
        b=y1SNpzrBW1ZtsTfsjz6aQAEdx2pxzDfSsBphTwiMOz2eByo6IOtYKGX8vT4ukU14WJ
         WJuhH68Y7lK2VLUuAxn/zsTuBTAv0RG89H4r9fIVd6+Uc7zTl5kFsORDrz9EdPOfTHuY
         gtgGfZoBL2uKjF0GddqWF2UZgvqydp7h1Wnot85y4OOvUFiRUOqDbN1Ds2oi9rztdlmu
         VEz5zLVV8ytcon6tMmgnSGoIZP0779B3OWijJEGbIqiStR3hpmwJAYojkdHVIqOEHzoU
         oflP3+xyuZW3rpeXH/h8+xBRpOjuIUkWvCGs/lpNkoh1vMQoWUU9xc7KWkjgwo3dZXFu
         Kz3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XFQFj3p1;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a198sor27772080ita.10.2019.01.10.01.42.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 01:42:27 -0800 (PST)
Received-SPF: pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XFQFj3p1;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=7M3wwWlrs4tEunRjESsdbGOWmA1PGb5ePkFyeLIYn0s=;
        b=XFQFj3p1SP2QJDcU3gBFb3u9l9bexs6I+041MpMUWePUK52JaeZJyLPJBfqpqDFdyK
         xD3bALmvzFSarfGgv1GX7H6eGwczUP0WZWiqoEvIm+Yj/FEFtZjesScezedyf9mcCLlv
         5/UWM/SfsnRkMpSKNoYgvsTL3JqWJc1e4cMLkjGo98xk1CiJ5S9/0T1Vhgq+x/IGdILb
         mujaNpdKPS0LcsDcGYe04BAgFJYXSZ2nxrLInUGj/418Ln3bfr6ZOUDVHQjVcGNJsKZO
         4zjO4js2LbU7p0mK+xkmLB9EbcyB6Lilc3w0v1C3EEZGqqatEYNCN/QRQagoPEo/LOrj
         oiyg==
X-Google-Smtp-Source: ALg8bN5KqwfZfEoNtMlDHYxJvuW97II95ryx891nWt4ynMBxWdNOu0vee72fKTwMKXPa5+RlqjIUtWBLGpYFxmMsESc=
X-Received: by 2002:a24:d04:: with SMTP id 4mr6268772itx.19.1547113346393;
 Thu, 10 Jan 2019 01:42:26 -0800 (PST)
MIME-Version: 1.0
References: <CABXGCsPu3g8WZXV1RpggLFuL3bgofmXMs1SiPyYnPyEOW7t3Dg@mail.gmail.com>
 <24702c72-cc06-1b54-0ab9-6d2409362c27@amd.com> <CABXGCsMPjKnCb7hpuenL5q3_HJgoGW=VB9FRrBpJsZMtA7LxpA@mail.gmail.com>
 <3ffe451b-1f17-23a5-985b-28d26fbaf7da@amd.com> <09781f6e-5ea3-ccfd-1aa2-79941b089863@amd.com>
 <CABXGCsPCACOhOo4DTCiOam65SiOiudrKpn5vKAL72bV6iGo9vA@mail.gmail.com>
 <CABXGCsMMSMJuURyhBQC3GuZc7m6Wq7FH=8_rpSWHrZT-0dJeGA@mail.gmail.com>
 <e1ced25f-4f35-320b-5208-7e1ca3565a3a@amd.com> <CABXGCsPPjz57=Et-V-_iGyY0GrEwfcK2QcRJcqiujUp90zaz-g@mail.gmail.com>
 <5a53e55f-91cf-759e-b52b-f4681083d639@amd.com> <CABXGCsMKMgzQBr4_QchVyc9JaN64cqDEY5dv29oRE5qhkaHH3g@mail.gmail.com>
 <52b47c08-a173-fafc-2a56-ec3cf44db99b@daenzer.net>
In-Reply-To: <52b47c08-a173-fafc-2a56-ec3cf44db99b@daenzer.net>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Thu, 10 Jan 2019 14:42:14 +0500
Message-ID:
 <CABXGCsMLZhOtDHpwL+U7=s7XHcDoRs3yauDBR81d0-j-Fo6f-g@mail.gmail.com>
Subject: Re: After Vega 56/64 GPU hang I unable reboot system
To: =?UTF-8?Q?Michel_D=C3=A4nzer?= <michel@daenzer.net>
Cc: "Grodzovsky, Andrey" <Andrey.Grodzovsky@amd.com>, 
	"Deucher, Alexander" <Alexander.Deucher@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"Wentland, Harry" <Harry.Wentland@amd.com>, "Koenig, Christian" <Christian.Koenig@amd.com>, 
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190110094214.MiwnPKg2MTkTh4w3oByxHkzEjLmSozpdYPFGvFNb14Y@z>

On Thu, 10 Jan 2019 at 13:54, Michel D=C3=A4nzer <michel@daenzer.net> wrote=
:
>
> Assuming that's using DXVK, it could be an issue between DXVK and RADV.
> I'd start by filing a bug report against RADV.
>

In the case of the last report, I agree it makes sense.
But from the beginning I started this discussion because "* ERROR *
ring gfx timeout" haunts me everywhere. For example I unable to unlock
computer after night. I connect via SSH and see in kernel log "* ERROR
* ring gfx timeout". Or another case I watching video on YouTube as
usual and some times computer are stuck. I again connect via SSH and
see in log "* ERROR * ring gfx timeout". So i am very tired from this
error and want really helps to fix it. But I suppose logs from dmesg
here is helpless. Then I asked the guys how to got really useful logs.
And Andrey was guide me how to do it with umr tool.
I am tried get logs with umr with well reproduced for me case.
So we are here.


--
Best Regards,
Mike Gavrilov.

