Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 065CD8E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 04:42:28 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id m128so10424760itd.3
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 01:42:28 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a198sor27772080ita.10.2019.01.10.01.42.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 01:42:27 -0800 (PST)
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
Message-ID: <CABXGCsMLZhOtDHpwL+U7=s7XHcDoRs3yauDBR81d0-j-Fo6f-g@mail.gmail.com>
Subject: Re: After Vega 56/64 GPU hang I unable reboot system
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Michel_D=C3=A4nzer?= <michel@daenzer.net>
Cc: "Grodzovsky, Andrey" <Andrey.Grodzovsky@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Wentland, Harry" <Harry.Wentland@amd.com>, "Koenig, Christian" <Christian.Koenig@amd.com>, "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>

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
