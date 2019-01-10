Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 785848E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 03:54:41 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id t199so3917423wmd.3
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 00:54:41 -0800 (PST)
Received: from netline-mail3.netline.ch (mail.netline.ch. [148.251.143.178])
        by mx.google.com with ESMTP id t14si10808339wrp.81.2019.01.10.00.54.39
        for <linux-mm@kvack.org>;
        Thu, 10 Jan 2019 00:54:39 -0800 (PST)
Subject: Re: After Vega 56/64 GPU hang I unable reboot system
References: <CABXGCsPu3g8WZXV1RpggLFuL3bgofmXMs1SiPyYnPyEOW7t3Dg@mail.gmail.com>
 <24702c72-cc06-1b54-0ab9-6d2409362c27@amd.com>
 <CABXGCsMPjKnCb7hpuenL5q3_HJgoGW=VB9FRrBpJsZMtA7LxpA@mail.gmail.com>
 <3ffe451b-1f17-23a5-985b-28d26fbaf7da@amd.com>
 <09781f6e-5ea3-ccfd-1aa2-79941b089863@amd.com>
 <CABXGCsPCACOhOo4DTCiOam65SiOiudrKpn5vKAL72bV6iGo9vA@mail.gmail.com>
 <CABXGCsMMSMJuURyhBQC3GuZc7m6Wq7FH=8_rpSWHrZT-0dJeGA@mail.gmail.com>
 <e1ced25f-4f35-320b-5208-7e1ca3565a3a@amd.com>
 <CABXGCsPPjz57=Et-V-_iGyY0GrEwfcK2QcRJcqiujUp90zaz-g@mail.gmail.com>
 <5a53e55f-91cf-759e-b52b-f4681083d639@amd.com>
 <CABXGCsMKMgzQBr4_QchVyc9JaN64cqDEY5dv29oRE5qhkaHH3g@mail.gmail.com>
From: =?UTF-8?Q?Michel_D=c3=a4nzer?= <michel@daenzer.net>
Message-ID: <52b47c08-a173-fafc-2a56-ec3cf44db99b@daenzer.net>
Date: Thu, 10 Jan 2019 09:54:37 +0100
MIME-Version: 1.0
In-Reply-To: <CABXGCsMKMgzQBr4_QchVyc9JaN64cqDEY5dv29oRE5qhkaHH3g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>, "Grodzovsky, Andrey" <Andrey.Grodzovsky@amd.com>
Cc: "Deucher, Alexander" <Alexander.Deucher@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Wentland, Harry" <Harry.Wentland@amd.com>, "Koenig, Christian" <Christian.Koenig@amd.com>, "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>

On 2019-01-09 10:12 p.m., Mikhail Gavrilov wrote:
> On Thu, 10 Jan 2019 at 01:35, Grodzovsky, Andrey
> <Andrey.Grodzovsky@amd.com> wrote:
>>
>> I think the 'verbose' flag causes it do dump so much output, maybe try without it in ALL the commands above.
>> Are you are aware of any particular application during which run this happens ?
>>
> 
> Last logs related to situation when I launch the game "Shadow of the
> Tomb Raider" via proton 3.16-16.
> Occurs every time when the game menu should appear after game launching.

Assuming that's using DXVK, it could be an issue between DXVK and RADV.
I'd start by filing a bug report against RADV.


-- 
Earthling Michel Dänzer               |               http://www.amd.com
Libre software enthusiast             |             Mesa and X developer
