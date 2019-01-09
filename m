Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 697FB8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 16:12:31 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id c4so7690200ioh.16
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 13:12:31 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 130sor23734729ita.7.2019.01.09.13.12.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 Jan 2019 13:12:29 -0800 (PST)
MIME-Version: 1.0
References: <CABXGCsPu3g8WZXV1RpggLFuL3bgofmXMs1SiPyYnPyEOW7t3Dg@mail.gmail.com>
 <24702c72-cc06-1b54-0ab9-6d2409362c27@amd.com> <CABXGCsMPjKnCb7hpuenL5q3_HJgoGW=VB9FRrBpJsZMtA7LxpA@mail.gmail.com>
 <3ffe451b-1f17-23a5-985b-28d26fbaf7da@amd.com> <09781f6e-5ea3-ccfd-1aa2-79941b089863@amd.com>
 <CABXGCsPCACOhOo4DTCiOam65SiOiudrKpn5vKAL72bV6iGo9vA@mail.gmail.com>
 <CABXGCsMMSMJuURyhBQC3GuZc7m6Wq7FH=8_rpSWHrZT-0dJeGA@mail.gmail.com>
 <e1ced25f-4f35-320b-5208-7e1ca3565a3a@amd.com> <CABXGCsPPjz57=Et-V-_iGyY0GrEwfcK2QcRJcqiujUp90zaz-g@mail.gmail.com>
 <5a53e55f-91cf-759e-b52b-f4681083d639@amd.com>
In-Reply-To: <5a53e55f-91cf-759e-b52b-f4681083d639@amd.com>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Thu, 10 Jan 2019 02:12:18 +0500
Message-ID: <CABXGCsMKMgzQBr4_QchVyc9JaN64cqDEY5dv29oRE5qhkaHH3g@mail.gmail.com>
Subject: Re: After Vega 56/64 GPU hang I unable reboot system
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Grodzovsky, Andrey" <Andrey.Grodzovsky@amd.com>
Cc: "Wentland, Harry" <Harry.Wentland@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Koenig, Christian" <Christian.Koenig@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>

On Thu, 10 Jan 2019 at 01:35, Grodzovsky, Andrey
<Andrey.Grodzovsky@amd.com> wrote:
>
> I think the 'verbose' flag causes it do dump so much output, maybe try without it in ALL the commands above.
> Are you are aware of any particular application during which run this happens ?
>

Last logs related to situation when I launch the game "Shadow of the
Tomb Raider" via proton 3.16-16.
Occurs every time when the game menu should appear after game launching.

--
Best Regards,
Mike Gavrilov.
