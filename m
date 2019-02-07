Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4DE84C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 21:12:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05E4920663
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 21:12:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=javigon-com.20150623.gappssmtp.com header.i=@javigon-com.20150623.gappssmtp.com header.b="aXjJ5Tzw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05E4920663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=javigon.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 87C5D8E0066; Thu,  7 Feb 2019 16:12:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 800178E0002; Thu,  7 Feb 2019 16:12:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C98D8E0066; Thu,  7 Feb 2019 16:12:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0DA618E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 16:12:22 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id 39so467525edq.13
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 13:12:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=3OME255Bf/uxB/3SsI2f37qTGiqhn3cF46//e7/7eVM=;
        b=VJqo0GrQGc/yfRUufUciFT2uAX1ALtfX7xW6tiMLy+CZpag+flPZ68Z5eFCPUnj4wW
         pAvRW917UeEOJ1ExqUVnVAhuCzq2iTKZwvez1IWMq88J0sJ0EV71uKRlycOk5toODD1K
         40GbW16zbxpIGDJq8oinU5ekaEnkjNZvkVo0mF4+YcC68o8d0ztuFOVeBq38NKHa7gp+
         G8BfjPG9bGr3zB0TkKFcSUpbtyLv6+ABmYTioBCID6+iAiDSZvRcdxRIkAfaJWzoHpjb
         nx4R4zXaoJiRrBg0BwxobL05WHLQ7IAtP/ehCBPHF5nhaY2Pzn4p6VZNefpjo333JqH+
         im4A==
X-Gm-Message-State: AHQUAubTI7i4daNxHUWP3ST/s4ZwW44gBO3TiK8nMhkJWwTwjyFRfWRQ
	2SLMExWnJ9NcY9lkMyFPItJrRtCFhZ8IUjQfvUAaOqLiWK6uxNMwlNfgpkescXvCunTLTBJcVX+
	yPhcHGoWAkm4HVACBzPjheITt2RqqxeUn7Bxit6mGyuWwuuWVOso4EWcD7VEhFto1dMYwKNEWvR
	9mS313sK5Go1sy9O9eAm0XtT8kqodcG/q1ZIJ6icEdBkTabF5TGkjOChz8pSqLyOBEPpMrq7WLw
	kK5wH06v/hN9JlybpmKF0Z/oRh2f4LZYXwGL8VS5MCcuT0kmwNeHhld6fi/DlGbWsllkpA3BWMy
	9JfREFgww396GX+TtMH4z8t2gpCAVaw0qEgysbBFdQQ7oeShkUISD4SfKiwUIZofy0bqJYWhYEe
	y
X-Received: by 2002:aa7:ccc8:: with SMTP id y8mr13418539edt.118.1549573941425;
        Thu, 07 Feb 2019 13:12:21 -0800 (PST)
X-Received: by 2002:aa7:ccc8:: with SMTP id y8mr13418493edt.118.1549573940401;
        Thu, 07 Feb 2019 13:12:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549573940; cv=none;
        d=google.com; s=arc-20160816;
        b=bfhEWEkcv2ggXRRpOg3zF97mvCAY+w8hhoa53zujNl3mBeqFVFBgJZE8bjoIrS3Gze
         9QLA/d8RSzCHeFILebsdV33QGsBq9p5GP26wUWShFgMeCtBXnvnm4z88yN/Vz9fjRNA7
         CpGejwICp24AkB0iqgR4hLS2nK85iyJmRoB2b9D/tTa0TDx4kUHHHgMKLsFCbwjhVmKw
         BdnMjfg/AHAJRTFPcoAo0UEozrsuTbkNCDuFXOUYyPJ7rZa9kc0PKOMvV3sLX6sN0b71
         q2KziyY5MecsY3YAgJg4MMZ2AiaBRYgUrLdq729isQH9/ijCZ00xqEMsDOl/eqdkfuWy
         kjww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=3OME255Bf/uxB/3SsI2f37qTGiqhn3cF46//e7/7eVM=;
        b=kJhG6WotHH4TPBedqczs+8/KNf90elovzbH2fKvCKKjJYltgUzRh9N5GyBSdNwglGY
         hTkZGkT016Ellw+FcZUoSigmUT2/GtLfhkfXRrqcFgOq2hTVHE+yqWSt/9ZjlZ1VETxq
         GtQPEJfutIG7EWotTzaDqbwblNnaPE2N45l/8jJrqEtpdfR+9C3ST/Ub50ogm4o5OGur
         99gEiRlsriVqu/7tO6/lEUEoMUeCDe8hck1Oc8lzre79FMDAugYTfn/r76CYu4IW2l7S
         xakNIGttq13X54sOSWrMzJiZISR9stoll6Zm/B0Hg/3GNPDTbF7uxj8Ff9OvhqRsaNcl
         8WAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@javigon-com.20150623.gappssmtp.com header.s=20150623 header.b=aXjJ5Tzw;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of javier@javigon.com) smtp.mailfrom=javier@javigon.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f3sor121608ejf.40.2019.02.07.13.12.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 13:12:20 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of javier@javigon.com) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@javigon-com.20150623.gappssmtp.com header.s=20150623 header.b=aXjJ5Tzw;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of javier@javigon.com) smtp.mailfrom=javier@javigon.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=javigon-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=3OME255Bf/uxB/3SsI2f37qTGiqhn3cF46//e7/7eVM=;
        b=aXjJ5Tzwh+JKJQi+wozKXYNGLa4+PvyuxjoYFE7gmYZKf8GKMjTGzFE6SNN0PpM6Mp
         6Sn93mrCqP1o/w58ktLo8ch9IfTdRN098Fk4BsxaNq4+uac6SVFZB0TD8ShZARC+hfAa
         gG3sjWz5vPHwWesu/AnTrJvez0utQltPlYlrPWE82hg+/DDVAnPVZ1BgCMf971ycorEC
         WI8CK/mJ4XpgsmekliZwJH4ZKM62mLnZnukRilJtlcGv7WUs0BCEwE+L9qW9ZrjSDbGq
         mXLPQVHT24umxnfcnKgB3Swl9XnOhjTdDYwHiInjwi+MOsAjc06Ry2EmBhbV1dwt15ya
         acow==
X-Google-Smtp-Source: AHgI3IZbcG80nPcvIKfmajw5SYcVA2Ll7XmgZuv3K3KMz3pRJI6mg6EpMQCqNU8oYloJjWif5ympgQ==
X-Received: by 2002:a17:906:a44:: with SMTP id x4-v6mr13083856ejf.177.1549573939763;
        Thu, 07 Feb 2019 13:12:19 -0800 (PST)
Received: from [192.168.1.143] (ip-5-186-122-168.cgn.fibianet.dk. [5.186.122.168])
        by smtp.gmail.com with ESMTPSA id l17sm101722edc.56.2019.02.07.13.12.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 13:12:19 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.1 \(3445.101.1\))
Subject: Re: [LSF/MM TOPIC] BPF for Block Devices
From: =?utf-8?Q?Javier_Gonz=C3=A1lez?= <javier@javigon.com>
In-Reply-To: <04952865-6EEE-4D78-8CC9-00484CFBD13E@javigon.com>
Date: Thu, 7 Feb 2019 22:12:17 +0100
Cc: Jens Axboe <axboe@kernel.dk>,
 linux-fsdevel <linux-fsdevel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>,
 "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>,
 IDE/ATA development list <linux-ide@vger.kernel.org>,
 linux-scsi <linux-scsi@vger.kernel.org>,
 "linux-nvme@lists.infradead.org" <linux-nvme@lists.infradead.org>,
 Logan Gunthorpe <logang@deltatee.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
 "bpf@vger.kernel.org" <bpf@vger.kernel.org>,
 "ast@kernel.org" <ast@kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <B6ABE829-3F3F-4612-943E-4899D91CEB1D@javigon.com>
References: <40D2EB06-6BF2-4233-9196-7A26AC43C64E@raithlin.com>
 <04952865-6EEE-4D78-8CC9-00484CFBD13E@javigon.com>
To: Stephen Bates <sbates@raithlin.com>
X-Mailer: Apple Mail (2.3445.101.1)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

+ Mailing lists

> On 7 Feb 2019, at 18.48, Javier Gonz=C3=A1lez <javier@javigon.com> =
wrote:
>=20
>=20
>=20
>> On 7 Feb 2019, at 18.12, Stephen Bates <sbates@raithlin.com> wrote:
>>=20
>> Hi All
>>=20
>>> A BPF track will join the annual LSF/MM Summit this year! Please =
read the updated description and CFP information below.
>>=20
>> Well if we are adding BPF to LSF/MM I have to submit a request to =
discuss BPF for block devices please!
>>=20
>> There has been quite a bit of activity around the concept of =
Computational Storage in the past 12 months. SNIA recently formed a =
Technical Working Group (TWG) and it is expected that this TWG will be =
making proposals to standards like NVM Express to add APIs for =
computation elements that reside on or near block devices.
>>=20
>> While some of these Computational Storage accelerators will provide =
fixed functions (e.g. a RAID, encryption or compression), others will be =
more flexible. Some of these flexible accelerators will be capable of =
running BPF code on them (something that certain Linux drivers for =
SmartNICs support today [1]). I would like to discuss what such a =
framework could look like for the storage layer and the file-system =
layer. I'd like to discuss how devices could advertise this capability =
(a special type of NVMe namespace or SCSI LUN perhaps?) and how the BPF =
engine could be programmed and then used against block IO. Ideally I'd =
like to discuss doing this in a vendor-neutral way and develop ideas I =
can take back to NVMe and the SNIA TWG to help shape how these standard =
evolve.
>>=20
>> To provide an example use-case one could consider a BPF capable =
accelerator being used to perform a filtering function and then using =
p2pdma to scan data on a number of adjacent NVMe SSDs, filtering said =
data and then only providing filter-matched LBAs to the host. Many other =
potential applications apply.=20
>>=20
>> Also, I am interested in the "The end of the DAX Experiment" topic =
proposed by Dan and the " Zoned Block Devices" from Matias and Damien.
>>=20
>> Cheers
>>=20
>> Stephen
>>=20
>> [1] =
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/dr=
ivers/net/ethernet/netronome/nfp/bpf/offload.c?h=3Dv5.0-rc5
>=20
> Definitely interested on this too - and pleasantly surprised to see a =
BPF track!
>=20
> I would like to extend Stephen=E2=80=99s discussion to eBPF running in =
the block layer directly - both on the kernel VM and offloaded to the =
accelerator of choice. This would be like XDP on the storage stack, =
possibly with different entry points. I have been doing some experiments =
building a dedup engine for pblk in the last couple of weeks and a =
number of interesting questions have arisen.
>=20
> Also, if there is a discussion on offloading the eBPF to an =
accelerator, I would like to discuss how we can efficiently support data =
modifications without having double transfers over either the PCIe bus =
(or worse, over the network): one for the data computation + =
modification and another for the actual data transfer. Something like =
p2pmem comes to mind here, but for this to integrate nicely, we would =
need to overcome the current limitations on PCIe and talk about p2pmem =
over fabrics.
>=20
> Javier

