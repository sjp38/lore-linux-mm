Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D88C6C282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 08:22:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79FD020818
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 08:22:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="Nrt1rsnB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79FD020818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 176DD8E007A; Tue,  5 Feb 2019 03:22:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 125F18E001C; Tue,  5 Feb 2019 03:22:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 014DE8E007A; Tue,  5 Feb 2019 03:22:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id D19808E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 03:22:32 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id k186so1036940ybk.21
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 00:22:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=kz3zeho6EvhbxURvMG/rWdNbC10QZyVhAT8x1eGGXPw=;
        b=JUjXxHK6KVYjyQN510Toe8LcOUmMMmWDcDrnI73bAwg9fJ9JQon4nzC+MDa24WD+yC
         Gg9s6FJjdcDC4NmKxF6EseTZZ1E//TrWXAlAoBOL943ha1rlEwDtL4f9GOAypObcyy5R
         wce+U91qVHS6q2KxtJq8i4aWNhFQyk4EUuxmz0w2R7P6tDVHBO+YbHbfMru4kH6AMPgg
         CnGgdyecH1b3wHYO+ZyGtdFvk8l5r1zZLqots7guccw6oH1uo0VvP6Yam6ZDnBXEmflL
         Ic0U8WGlz2i7SQ73htnxOzFR1FoTpGq6tXb7nwzKZ7nAX6R2VxfMGqhzsaKGF5ljtXp/
         xWIg==
X-Gm-Message-State: AHQUAuanQHslSkjcZiR0TseDrcfJMCMUSyIhrH4ACQ7/xy9WlgVI2NMh
	O9KHht+tHJnrGlgFxCQFLuQs07t8Q3GEwbHxAdN+WOzceFCQXMuRUxU8MT+H406f0rBcrw9emWl
	I4VZkzrYZHx9hrA+e6kkX7SJlklxRlrPt2GAJmb5VNUNMw036g/cGHVyC5Gdp67qlfw==
X-Received: by 2002:a25:4292:: with SMTP id p140mr2894175yba.240.1549354952445;
        Tue, 05 Feb 2019 00:22:32 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaXTBVG2mBSDRJ0CRBX5+mlEkUau0NeY7hBImMxIm5LCBiynTJsPwetzPJzT0MAhBHC0+8H
X-Received: by 2002:a25:4292:: with SMTP id p140mr2894137yba.240.1549354951500;
        Tue, 05 Feb 2019 00:22:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549354951; cv=none;
        d=google.com; s=arc-20160816;
        b=Z7p8ATw8gqBuGVPPS7jArwvtEDJdphCN9DOhKHz2z+14+AmRFcb/hsmAjqUCag1tQt
         oPZGRMrT5OnIybDWOHXw2DULkalskk3te5LMF35bpgE7+7RLM5rQrNhClLpGsM+JfGHE
         6WBzRFztq/dVBeNUW7kGggbNZLk0hqFJk0Fd6/v5RpK+r+H4ghGkU9fkXk93ryV3+1B9
         U6BRgQZ8w+B3fX6+p49lp/WuKhVm0nO6rcCbEfgxKZeSXCl9P7GG2MMmydTbequTlu9O
         vdDCYTtTiiyAF7Y+0wvQEiqEFp2JpiemAYxMQUtr38npGtKzPi5djObQbTwouWCCBr9v
         xhjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=kz3zeho6EvhbxURvMG/rWdNbC10QZyVhAT8x1eGGXPw=;
        b=D2ww+iX6wDCWmhnaPQI4kngdW/byWamuvvRveksyyGGkW32mpSvx4sHkJQDDUCJy7G
         7zJKj8IABJo/a9wfVJHp0lEhFP1l9uy0V57CzLiuEPWBaDvXUWvpaSYcvCu45Ig25LUO
         PLqM7+AcZE+Wm4W49n/Bo+HmoZT0GWlvBJC0Rv2chVUyrFacR5dspOxlq7a0WuLNVrPG
         V1dPFiWtGyYIAWc9k6A6pf+RNlxhWUNe/F8wuyUH7ch8UfZDONGf31Gy6nvGepI+lf39
         Xz9gyfZVsxcPNBi6wcu5JFTd3dbnmoigBmeMq6n2KCaiOKMBBvvmOAMDCJlEUoQuToeZ
         Pynw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Nrt1rsnB;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id i194si1568865ywg.151.2019.02.05.00.22.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 00:22:31 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Nrt1rsnB;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c5947c80000>; Tue, 05 Feb 2019 00:22:32 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 05 Feb 2019 00:22:29 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 05 Feb 2019 00:22:29 -0800
Received: from [10.2.164.51] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Tue, 5 Feb
 2019 08:22:28 +0000
Subject: Re: [PATCH 0/6] RFC v2: mm: gup/dma tracking
To: Tom Talpey <tom@talpey.com>, <john.hubbard@gmail.com>, Andrew Morton
	<akpm@linux-foundation.org>, <linux-mm@kvack.org>
CC: Al Viro <viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>,
	Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>, Doug Ledford
	<dledford@redhat.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox
	<willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Mike Rapoport
	<rppt@linux.ibm.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Ralph
 Campbell <rcampbell@nvidia.com>, LKML <linux-kernel@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>
References: <20190204052135.25784-1-jhubbard@nvidia.com>
 <dbca5400-b0c0-0958-c3ba-ff672f301799@talpey.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <80d503f5-038b-7f0b-90d5-e5b9537ae1df@nvidia.com>
Date: Tue, 5 Feb 2019 00:22:40 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <dbca5400-b0c0-0958-c3ba-ff672f301799@talpey.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1549354952; bh=kz3zeho6EvhbxURvMG/rWdNbC10QZyVhAT8x1eGGXPw=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=Nrt1rsnB6BTAVLqc91OHTHPHw+X7x1BJN4vWnLsTnMEnQSL/2lSGsuMY+nbmWvhoU
	 9mHnBGTlESe+DwV6zjuz08qt4LHgs8jzxXkY/IjmSwBbX48Unx54wLUmrgk9+gx3zj
	 hKsUTkwtc7bu3tlgpiGrur/i2FfZEFGljStLOID+EfOMymW/1ZtrAsmibkgGpi9wVA
	 nsLIdPjKrWgSqHx8celGrc8W6BFZhxDPHTBdZJthg0oXXxU6c9kgGhCjhl4o0dD2wl
	 qjuVSoCIi6DgsT58bGFh689S18EHHuCQ2TkKCYj2PNGgWlueBhjfnrTYaWfmJ0kJK6
	 X6ZV2Wsn6RWmQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/4/19 5:41 PM, Tom Talpey wrote:
> On 2/4/2019 12:21 AM, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
>>
>>
>> Performance: here is an fio run on an NVMe drive, using this for the fio
>> configuration file:
>>
>> =C2=A0=C2=A0=C2=A0=C2=A0 [reader]
>> =C2=A0=C2=A0=C2=A0=C2=A0 direct=3D1
>> =C2=A0=C2=A0=C2=A0=C2=A0 ioengine=3Dlibaio
>> =C2=A0=C2=A0=C2=A0=C2=A0 blocksize=3D4096
>> =C2=A0=C2=A0=C2=A0=C2=A0 size=3D1g
>> =C2=A0=C2=A0=C2=A0=C2=A0 numjobs=3D1
>> =C2=A0=C2=A0=C2=A0=C2=A0 rw=3Dread
>> =C2=A0=C2=A0=C2=A0=C2=A0 iodepth=3D64
>>
>> reader: (g=3D0): rw=3Dread, bs=3D(R) 4096B-4096B, (W) 4096B-4096B, (T)=20
>> 4096B-4096B, ioengine=3Dlibaio, iodepth=3D64
>> fio-3.3
>> Starting 1 process
>> Jobs: 1 (f=3D1)
>> reader: (groupid=3D0, jobs=3D1): err=3D 0: pid=3D7011: Sun Feb=C2=A0 3 2=
0:36:51 2019
>> =C2=A0=C2=A0=C2=A0 read: IOPS=3D190k, BW=3D741MiB/s (778MB/s)(1024MiB/13=
81msec)
>> =C2=A0=C2=A0=C2=A0=C2=A0 slat (nsec): min=3D2716, max=3D57255, avg=3D404=
8.14, stdev=3D1084.10
>> =C2=A0=C2=A0=C2=A0=C2=A0 clat (usec): min=3D20, max=3D12485, avg=3D332.6=
3, stdev=3D191.77
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 lat (usec): min=3D22, max=3D12498, avg=3D=
336.72, stdev=3D192.07
>> =C2=A0=C2=A0=C2=A0=C2=A0 clat percentiles (usec):
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0 1.00th=3D[=C2=A0 322],=C2=A0 5.00=
th=3D[=C2=A0 322], 10.00th=3D[=C2=A0 322], 20.00th=3D[ =20
>> 326],
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 | 30.00th=3D[=C2=A0 326], 40.00th=3D[=C2=
=A0 326], 50.00th=3D[=C2=A0 326], 60.00th=3D[ =20
>> 326],
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 | 70.00th=3D[=C2=A0 326], 80.00th=3D[=C2=
=A0 330], 90.00th=3D[=C2=A0 330], 95.00th=3D[ =20
>> 330],
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 | 99.00th=3D[=C2=A0 478], 99.50th=3D[=C2=
=A0 717], 99.90th=3D[ 1074], 99.95th=3D[=20
>> 1090],
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 | 99.99th=3D[12256]
>=20
> These latencies are concerning. The best results we saw at the end of
> November (previous approach) were MUCH flatter. These really start
> spiking at three 9's, and are sky-high at four 9's. The "stdev" values
> for clat and lat are about 10 times the previous. There's some kind
> of serious queuing contention here, that wasn't there in November.

Hi Tom,

I think this latency problem is also there in the baseline kernel, but...

>=20
>> =C2=A0=C2=A0=C2=A0 bw (=C2=A0 KiB/s): min=3D730152, max=3D776512, per=3D=
99.22%, avg=3D753332.00,=20
>> stdev=3D32781.47, samples=3D2
>> =C2=A0=C2=A0=C2=A0 iops=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : min=
=3D182538, max=3D194128, avg=3D188333.00,=20
>> stdev=3D8195.37, samples=3D2
>> =C2=A0=C2=A0 lat (usec)=C2=A0=C2=A0 : 50=3D0.01%, 100=3D0.01%, 250=3D0.0=
7%, 500=3D99.26%, 750=3D0.38%
>> =C2=A0=C2=A0 lat (usec)=C2=A0=C2=A0 : 1000=3D0.02%
>> =C2=A0=C2=A0 lat (msec)=C2=A0=C2=A0 : 2=3D0.24%, 20=3D0.02%
>> =C2=A0=C2=A0 cpu=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 :=
 usr=3D15.07%, sys=3D84.13%, ctx=3D10, majf=3D0, minf=3D74
>=20
> System CPU 84% is roughly double the November results of 45%. Ouch.

That's my fault. First of all, I had a few extra, supposedly minor debug
settings in the .config, which I'm removing now--I'm doing a proper run
with the original .config file from November, below. Second, I'm not
sure I controlled the run carefully enough.

>=20
> Did you re-run the baseline on the new unpatched base kernel and can
> we see the before/after?

Doing that now, I see:

-- No significant perf difference between before and after, but
-- Still high clat in the 99.99th

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Before: using commit 8834f5600cf3 ("Linux 5.0-rc5")
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
reader: (g=3D0): rw=3Dread, bs=3D(R) 4096B-4096B, (W) 4096B-4096B, (T)=20
4096B-4096B, ioengine=3Dlibaio, iodepth=3D64
fio-3.3
Starting 1 process
Jobs: 1 (f=3D1)
reader: (groupid=3D0, jobs=3D1): err=3D 0: pid=3D1829: Tue Feb  5 00:08:08 =
2019
    read: IOPS=3D193k, BW=3D753MiB/s (790MB/s)(1024MiB/1359msec)
     slat (nsec): min=3D1269, max=3D40309, avg=3D1493.66, stdev=3D534.83
     clat (usec): min=3D127, max=3D12249, avg=3D329.83, stdev=3D184.92
      lat (usec): min=3D129, max=3D12256, avg=3D331.35, stdev=3D185.06
     clat percentiles (usec):
      |  1.00th=3D[  326],  5.00th=3D[  326], 10.00th=3D[  326], 20.00th=3D=
[  326],
      | 30.00th=3D[  326], 40.00th=3D[  326], 50.00th=3D[  326], 60.00th=3D=
[  326],
      | 70.00th=3D[  326], 80.00th=3D[  326], 90.00th=3D[  326], 95.00th=3D=
[  326],
      | 99.00th=3D[  347], 99.50th=3D[  519], 99.90th=3D[  529], 99.95th=3D=
[  537],
      | 99.99th=3D[12125]
    bw (  KiB/s): min=3D755032, max=3D781472, per=3D99.57%, avg=3D768252.00=
,=20
stdev=3D18695.90, samples=3D2
    iops        : min=3D188758, max=3D195368, avg=3D192063.00, stdev=3D4673=
.98,=20
samples=3D2
   lat (usec)   : 250=3D0.08%, 500=3D99.18%, 750=3D0.72%
   lat (msec)   : 20=3D0.02%
   cpu          : usr=3D12.30%, sys=3D46.83%, ctx=3D253554, majf=3D0, minf=
=3D74
   IO depths    : 1=3D0.1%, 2=3D0.1%, 4=3D0.1%, 8=3D0.1%, 16=3D0.1%, 32=3D0=
.1%,=20
 >=3D64=3D100.0%
      submit    : 0=3D0.0%, 4=3D100.0%, 8=3D0.0%, 16=3D0.0%, 32=3D0.0%, 64=
=3D0.0%,=20
 >=3D64=3D0.0%
      complete  : 0=3D0.0%, 4=3D100.0%, 8=3D0.0%, 16=3D0.0%, 32=3D0.0%, 64=
=3D0.1%,=20
 >=3D64=3D0.0%
      issued rwts: total=3D262144,0,0,0 short=3D0,0,0,0 dropped=3D0,0,0,0
      latency   : target=3D0, window=3D0, percentile=3D100.00%, depth=3D64

Run status group 0 (all jobs):
    READ: bw=3D753MiB/s (790MB/s), 753MiB/s-753MiB/s (790MB/s-790MB/s),=20
io=3D1024MiB (1074MB), run=3D1359-1359msec

Disk stats (read/write):
   nvme0n1: ios=3D221246/0, merge=3D0/0, ticks=3D71556/0, in_queue=3D704,=20
util=3D91.35%

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
After:
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
reader: (g=3D0): rw=3Dread, bs=3D(R) 4096B-4096B, (W) 4096B-4096B, (T)=20
4096B-4096B, ioengine=3Dlibaio, iodepth=3D64
fio-3.3
Starting 1 process
Jobs: 1 (f=3D1)
reader: (groupid=3D0, jobs=3D1): err=3D 0: pid=3D1803: Mon Feb  4 23:58:07 =
2019
    read: IOPS=3D193k, BW=3D753MiB/s (790MB/s)(1024MiB/1359msec)
     slat (nsec): min=3D1276, max=3D41900, avg=3D1505.36, stdev=3D565.26
     clat (usec): min=3D177, max=3D12186, avg=3D329.88, stdev=3D184.03
      lat (usec): min=3D178, max=3D12192, avg=3D331.42, stdev=3D184.16
     clat percentiles (usec):
      |  1.00th=3D[  326],  5.00th=3D[  326], 10.00th=3D[  326], 20.00th=3D=
[  326],
      | 30.00th=3D[  326], 40.00th=3D[  326], 50.00th=3D[  326], 60.00th=3D=
[  326],
      | 70.00th=3D[  326], 80.00th=3D[  326], 90.00th=3D[  326], 95.00th=3D=
[  326],
      | 99.00th=3D[  359], 99.50th=3D[  498], 99.90th=3D[  537], 99.95th=3D=
[  627],
      | 99.99th=3D[12125]
    bw (  KiB/s): min=3D754656, max=3D781504, per=3D99.55%, avg=3D768080.00=
,=20
stdev=3D18984.40, samples=3D2
    iops        : min=3D188664, max=3D195378, avg=3D192021.00, stdev=3D4747=
.51,=20
samples=3D2
   lat (usec)   : 250=3D0.12%, 500=3D99.40%, 750=3D0.46%
   lat (msec)   : 20=3D0.02%
   cpu          : usr=3D12.44%, sys=3D47.05%, ctx=3D252127, majf=3D0, minf=
=3D73
   IO depths    : 1=3D0.1%, 2=3D0.1%, 4=3D0.1%, 8=3D0.1%, 16=3D0.1%, 32=3D0=
.1%,=20
 >=3D64=3D100.0%
      submit    : 0=3D0.0%, 4=3D100.0%, 8=3D0.0%, 16=3D0.0%, 32=3D0.0%, 64=
=3D0.0%,=20
 >=3D64=3D0.0%
      complete  : 0=3D0.0%, 4=3D100.0%, 8=3D0.0%, 16=3D0.0%, 32=3D0.0%, 64=
=3D0.1%,=20
 >=3D64=3D0.0%
      issued rwts: total=3D262144,0,0,0 short=3D0,0,0,0 dropped=3D0,0,0,0
      latency   : target=3D0, window=3D0, percentile=3D100.00%, depth=3D64

Run status group 0 (all jobs):
    READ: bw=3D753MiB/s (790MB/s), 753MiB/s-753MiB/s (790MB/s-790MB/s),=20
io=3D1024MiB (1074MB), run=3D1359-1359msec

Disk stats (read/write):
   nvme0n1: ios=3D221203/0, merge=3D0/0, ticks=3D71291/0, in_queue=3D704,=20
util=3D91.19%

How's this look to you?

thanks,
--=20
John Hubbard
NVIDIA

