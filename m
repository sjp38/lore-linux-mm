Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB73AC282CB
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 08:31:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5AB3221917
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 08:31:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lightnvm-io.20150623.gappssmtp.com header.i=@lightnvm-io.20150623.gappssmtp.com header.b="d4jlx/3n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AB3221917
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lightnvm.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B87758E0084; Fri,  8 Feb 2019 03:31:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B36178E0083; Fri,  8 Feb 2019 03:31:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4A488E0084; Fri,  8 Feb 2019 03:31:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 372818E0083
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 03:31:26 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id t22-v6so765101lji.14
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 00:31:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=e9o0xEZeVxGkGRYq+FrqLeZRYKbVYwBBNVU1Vhi1O7c=;
        b=ke6c+tnZjLY5bhf5apx0SX0Mfa+YuqfeJWmQ9b0teUEl0I5d0zsxWGID89b2VnnBHY
         hUnf1lplDIR/pSPqX7ddnZ9cdIpevXUarEn7l5P3LdQvSGFhIUvMVaAwcYp82GbmwsIH
         HHUU7c9SF4duCEsGDtkpWEGhXXSIy7TZtweR4/eNsMLFdJ1GolcIBor5ZbENdcq12JL8
         hRRur4vJn4cENexhIMEUM+LDeTqwCCzLCTo8T09HsDuGfZZRTuTR7dwHeLTwoNPNWYGU
         frEiZ/hKNNYFzhFo6r6Jb/0pnkkHsKXEyi6+BosTVBmrEGk/0xkIGtkfOIesoJvhDqnL
         pvOQ==
X-Gm-Message-State: AHQUAuYwCb4CG/HmfpUQtmPQWONVtdBQsack1j6Qjr52fczh9JdQ+RYo
	eOjCGjznHcU5zixDSsPIEo+hH2hcSXDpNKaObWrkL0s3pqv38c9EL5qaVHTr3goWoc/Jg771RxY
	QXdMV6xglBsThHlXAjWN3xOkP0svQPwjRknq4rSHGmeW70888fw6by+GOizuqnt2nQdG2yktWc9
	JwjxsEUUBO/q5tytTKCLZNMA+0KCjELK3xz4SHA5TVBMO4Y/88B/MEGS8Z3TCNAgbvcwBaQkSQd
	hisjppjWQm7JBv6oAuGdo4/Vgp4yR+chseV1xx73j490dGeGTCrlsXnicRky5MRVuimStIUf1D/
	DOaCeFgs9jGEgif1kfUP8fPIMdxkWhrQOFtLMmw4l5aS66pUzTJG2vO/6f1A44TTfrzDZXAhu/a
	V
X-Received: by 2002:a19:f244:: with SMTP id d4mr297390lfk.0.1549614685454;
        Fri, 08 Feb 2019 00:31:25 -0800 (PST)
X-Received: by 2002:a19:f244:: with SMTP id d4mr297320lfk.0.1549614684047;
        Fri, 08 Feb 2019 00:31:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549614684; cv=none;
        d=google.com; s=arc-20160816;
        b=vfyWfD4SGEL5dDpYhCMd2YLhsGhbV/bvVHREF+EvkpoZ7FlqYtK5ks1J4sKAiy7GbX
         REbJmQBN1pCM4yil8VSJ0Lu8+Bd4tw7bzCjkBP1YsgZN49lF7Yyqq9CyVMEb3fjpLRfI
         6mXeb/qxzpUEqRN7Ufjsv9Ozo4iEbp4J/EcqZKaWDJLu2wU0gm1du9b525niEGHRAKed
         OFBVGurBA7qpuqmUT6dBRnKPwdF1kWupXyX4I/hPbe/iwRUcHuPB2cqvLFe2WJm+llmj
         ZPM2VTwK86MSVHHGTjsClOHOtB4hzjueoElyAy6+iuDT3+PMxzpx+QANoAd7mHKNNpJN
         qXkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=e9o0xEZeVxGkGRYq+FrqLeZRYKbVYwBBNVU1Vhi1O7c=;
        b=H+ROLrZydfqMZ9D24Qe+lyN6kmtyi7tphP00pktPjg/++q+Gzr35bqN02J+A8Wskhg
         sfNfbE/7l8SHPZFlgI3MZo30/wlMSFVa1cIrBAjOpaC1UpaeJAi1fpYjlJvvUKA2TC9l
         iCmgVnFFP2eMDDX5+8dIsNs0cHgxZylvyoZT0nSG816HWVbJzzc+Aan5mR3YqrND1hsQ
         36YTV+hSKLbFnLoPbuPPGFwPo+n3EGy/ZhQQTQLetMDXUsY6N8vAYjoVn4jf37jWoU+z
         lN0u6CNlruLVtgAVSX3Fy35A2ESEIVSmJJPXhoWvz9Qujb6ROeXJl9ZKKgrnL1uDM7C5
         2KCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lightnvm-io.20150623.gappssmtp.com header.s=20150623 header.b="d4jlx/3n";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of mb@lightnvm.io) smtp.mailfrom=mb@lightnvm.io
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u20sor347418lfl.64.2019.02.08.00.31.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Feb 2019 00:31:23 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of mb@lightnvm.io) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lightnvm-io.20150623.gappssmtp.com header.s=20150623 header.b="d4jlx/3n";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of mb@lightnvm.io) smtp.mailfrom=mb@lightnvm.io
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lightnvm-io.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=e9o0xEZeVxGkGRYq+FrqLeZRYKbVYwBBNVU1Vhi1O7c=;
        b=d4jlx/3nA/a5G7syHqg2prvdxFpGgbBoY21yMrmJkBeBq03jK/tjjyC3ad2yAifFhc
         cPqTUdPHzxs6WThF95eB9FAe9zclG3k1aJ6TbaJQfqbbDhbOwpGG9CT08esoy9vCiZLE
         +/mPVCXFiYcAHBKiBrj+1FxDmKNJkHjCJJejVnz5i4b7PkKqVIrfU+pinba2vLJTbN6g
         SETyheeaOhPNNm5rbtFCOdNTVLQvlzpQ/iuWf2nvSRt6SB04KW/OwluWcPTRQTXlpzsw
         JuhdbPvzy9BLv5fNtao3neUBWc3QWFsTFa7+e7xQpCTB9dvD7ykGqkh6EfBwWGQr+WE5
         jYAA==
X-Google-Smtp-Source: AHgI3IbZa/PxvTalxyrFemw0ERdwLiKEJ13PYlnSQyzLL5Wel6ke7icNnqLupvzfVXuGjkiT0Rh4+A==
X-Received: by 2002:a19:9508:: with SMTP id x8mr12577498lfd.112.1549614683327;
        Fri, 08 Feb 2019 00:31:23 -0800 (PST)
Received: from [192.168.0.36] (2-111-91-225-cable.dk.customer.tdc.net. [2.111.91.225])
        by smtp.googlemail.com with ESMTPSA id q10-v6sm239573ljj.3.2019.02.08.00.31.21
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 00:31:22 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] BPF for Block Devices
To: Stephen Bates <sbates@raithlin.com>, Jens Axboe <axboe@kernel.dk>,
 linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm
 <linux-mm@kvack.org>,
 "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>,
 IDE/ATA development list <linux-ide@vger.kernel.org>,
 linux-scsi <linux-scsi@vger.kernel.org>,
 "linux-nvme@lists.infradead.org" <linux-nvme@lists.infradead.org>,
 Logan Gunthorpe <logang@deltatee.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
 "bpf@vger.kernel.org" <bpf@vger.kernel.org>, "ast@kernel.org"
 <ast@kernel.org>
References: <40D2EB06-6BF2-4233-9196-7A26AC43C64E@raithlin.com>
From: =?UTF-8?Q?Matias_Bj=c3=b8rling?= <mb@lightnvm.io>
Message-ID: <f1f00282-11be-1682-3802-c8bd0e6fec4b@lightnvm.io>
Date: Fri, 8 Feb 2019 09:31:20 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <40D2EB06-6BF2-4233-9196-7A26AC43C64E@raithlin.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/7/19 6:12 PM, Stephen  Bates wrote:
> Hi All
> 
>> A BPF track will join the annual LSF/MM Summit this year! Please read the updated description and CFP information below.
> 
> Well if we are adding BPF to LSF/MM I have to submit a request to discuss BPF for block devices please!
> 
> There has been quite a bit of activity around the concept of Computational Storage in the past 12 months. SNIA recently formed a Technical Working Group (TWG) and it is expected that this TWG will be making proposals to standards like NVM Express to add APIs for computation elements that reside on or near block devices.
> 
> While some of these Computational Storage accelerators will provide fixed functions (e.g. a RAID, encryption or compression), others will be more flexible. Some of these flexible accelerators will be capable of running BPF code on them (something that certain Linux drivers for SmartNICs support today [1]). I would like to discuss what such a framework could look like for the storage layer and the file-system layer. I'd like to discuss how devices could advertise this capability (a special type of NVMe namespace or SCSI LUN perhaps?) and how the BPF engine could be programmed and then used against block IO. Ideally I'd like to discuss doing this in a vendor-neutral way and develop ideas I can take back to NVMe and the SNIA TWG to help shape how these standard evolve.
> 
> To provide an example use-case one could consider a BPF capable accelerator being used to perform a filtering function and then using p2pdma to scan data on a number of adjacent NVMe SSDs, filtering said data and then only providing filter-matched LBAs to the host. Many other potential applications apply.
> 
> Also, I am interested in the "The end of the DAX Experiment" topic proposed by Dan and the " Zoned Block Devices" from Matias and Damien.
> 
> Cheers
>   
> Stephen
> 
> [1] https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/net/ethernet/netronome/nfp/bpf/offload.c?h=v5.0-rc5
>   
>      
> 

If we're going down that road, we can also look at the block I/O path 
itself.

Now that Jens' has shown that io_uring can beat SPDK. Let's take it a 
step further, and create an API, such that we can bypass the boilerplate 
checking in kernel block I/O path, and go straight to issuing the I/O in 
the block layer.

For example, we could provide an API that allows applications to 
register a fast path through the kernel — one where checks, such as 
generic_make_request_checks(), already has been validated.

The user-space application registers a BFP program with the kernel, the 
kernel prechecks the possible I/O patterns and then green-lights all 
I/Os that goes through that unit. In that way, the checks only have to 
be done once, instead of every I/O. This approach could work beautifully 
with direct io and raw devices, and with a bit more work, we can do more 
complex use-cases as well.

