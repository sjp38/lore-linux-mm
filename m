Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id A202E8E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 05:38:45 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id f18so2999440wrt.1
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 02:38:45 -0800 (PST)
Received: from netline-mail3.netline.ch (mail.netline.ch. [148.251.143.178])
        by mx.google.com with ESMTP id g1si10807106wmg.78.2019.01.10.02.38.43
        for <linux-mm@kvack.org>;
        Thu, 10 Jan 2019 02:38:44 -0800 (PST)
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
 <52b47c08-a173-fafc-2a56-ec3cf44db99b@daenzer.net>
 <CABXGCsMLZhOtDHpwL+U7=s7XHcDoRs3yauDBR81d0-j-Fo6f-g@mail.gmail.com>
From: =?UTF-8?Q?Michel_D=c3=a4nzer?= <michel@daenzer.net>
Message-ID: <32ddb143-796d-11cd-549f-7757ef42e9ed@daenzer.net>
Date: Thu, 10 Jan 2019 11:38:42 +0100
MIME-Version: 1.0
In-Reply-To: <CABXGCsMLZhOtDHpwL+U7=s7XHcDoRs3yauDBR81d0-j-Fo6f-g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: "Grodzovsky, Andrey" <Andrey.Grodzovsky@amd.com>, "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Wentland, Harry" <Harry.Wentland@amd.com>, "Koenig, Christian" <Christian.Koenig@amd.com>

On 2019-01-10 10:42 a.m., Mikhail Gavrilov wrote:
> On Thu, 10 Jan 2019 at 13:54, Michel Dänzer <michel@daenzer.net> wrote:
>>
>> Assuming that's using DXVK, it could be an issue between DXVK and RADV.
>> I'd start by filing a bug report against RADV.
> 
> In the case of the last report, I agree it makes sense.
> But from the beginning I started this discussion because "* ERROR *
> ring gfx timeout" haunts me everywhere. For example I unable to unlock
> computer after night. I connect via SSH and see in kernel log "* ERROR
> * ring gfx timeout". Or another case I watching video on YouTube as
> usual and some times computer are stuck. I again connect via SSH and
> see in log "* ERROR * ring gfx timeout". So i am very tired from this
> error and want really helps to fix it. But I suppose logs from dmesg
> here is helpless.

Kind of; those are generic symptoms of a GPU hang, which can be caused
by many different things across the driver stack. Each separate cause
needs to be investigated separately. Hangs which are consistently
reproducible with certain applications are more likely due to userspace
issues, whereas hangs which occur inconsistently are more likely due to
kernel issues.


-- 
Earthling Michel Dänzer               |               http://www.amd.com
Libre software enthusiast             |             Mesa and X developer
