Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04B7DC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:47:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B57EB2084D
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:47:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="GUcJJ46s"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B57EB2084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 510D48E00AC; Thu, 21 Feb 2019 13:47:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4BFC58E00A9; Thu, 21 Feb 2019 13:47:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B3288E00AC; Thu, 21 Feb 2019 13:47:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0FB3B8E00A9
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 13:47:25 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id d134so5912903qkc.17
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 10:47:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=+03TOXK0U9ppV6eYP+I7x9IKOSuKY/sng539JPMt1WU=;
        b=GmQCGednRhFTRPTbr3Urz6aenOFDWltYah2dNXbPRPw7zGRnmd6F3gjbXCss3qbTSx
         kmNz3zUa0CGC6eBLNk8iSVRFdlfNY0kBobRLKEqhh7w+iu1/WaC4gO6NKLHzmNg9qS1a
         NCP9720OOhcIcyw5bhupCMSPiiAH7autfN6mBHd/KUOukOJfSBuVlK4u/3+w7QmS50bo
         iGHXXwT6wDBaQYnszIEPWmpH4LmCTPAbPu+si54BOCxlXCryUCWN3KCP511awv4YTm+i
         onnKVmuhvM+y5EDLTG450X3Fxlkkbie9D+MRItuAkNQI1ZHUPN96o0nkqlUKUmPg4uih
         R8Iw==
X-Gm-Message-State: AHQUAua8FMNZwzIHluV7grpLV+fmp2kIK1lPpJLvuuKg9FzuvuTF2kSD
	y97OlzmMTe1Alu265PVkRCD3ROxN1xJk9c5/QkMcTQrHFvd/VeuB8JKHBZWOFVJu/AdS7A9ZHMB
	7QAd9ABvt+UwNLR7iD9JJVLUxJhNilsuh/FUKBwTXYxcXA2381xdzSdXbgGV5SOU=
X-Received: by 2002:a37:4145:: with SMTP id o66mr28800217qka.129.1550774844805;
        Thu, 21 Feb 2019 10:47:24 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia+vIdcLk4UR1azsPpAJnholUQ0SiQbwMQkHSPnYii0Citf/FKp3KEWeb1y6mvNKvLMaZbZ
X-Received: by 2002:a37:4145:: with SMTP id o66mr28800184qka.129.1550774844158;
        Thu, 21 Feb 2019 10:47:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550774844; cv=none;
        d=google.com; s=arc-20160816;
        b=diBmTBx59xzNp3eVPl0mak11D10xxHlBIDpTvtaVygvisS31OsTbJx8KszaYnkgFtT
         EB+OQ5PLKpnCrAlRbSCrqIwhO/zuZxm4W197NgXmSEdo5/D4r+RH6sH9uh44Alu9Qpu5
         3DdJR4GNFn7NU9X/Kp6YApoB1ZRHhtMEDpH0hZCFoPPAjdREQmg3PvD66PDmhmAxvWrn
         VXiR7RKWteWX5VTbmsZ8o/ZHBmLwFdsFB33ipycFVUYAOBiu5FwvMXEJJNYkn6a9u0VL
         dIot4u7SOAnIIOmXMsEbwhtbwO5PVDaCIk1IJrglI4I9ItY2kvQOrIFudGniQiP9M30x
         OEDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=+03TOXK0U9ppV6eYP+I7x9IKOSuKY/sng539JPMt1WU=;
        b=R2d0bpDrqjH0ZHlxvORfq2e5qMb5oxBUoeQTF2OS+YE17ReYVJnL88uSX7V8M+KckT
         hf/D2gzu/I2odTaF28l0TVcrlCvNfeGPaLQ/gd2la6p8QPHK0N7vgp1JsUzF47J/BKBd
         rNnJTGMHvwWjkh6p6idETJBhB8W6W2c40WgmBlr/KiZdNNdu/Oz16xxK7IclBmYFghvc
         gG3UjBNxdgZmJD/xIqteLgnuPOgqL/hdIuDljghKuTVhRgV1QVTuheV0gb1/k+fyeCNP
         guNj0/ritemH0h4NKPuLVzgdS272O6PcrW6uymohaPiFcAeACDr6+hDtnJku5a75WbEc
         QLjA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=GUcJJ46s;
       spf=pass (google.com: domain of 0100016911623854-e69813aa-5820-4a46-a5d8-eb2943a83056-000000@amazonses.com designates 54.240.9.36 as permitted sender) smtp.mailfrom=0100016911623854-e69813aa-5820-4a46-a5d8-eb2943a83056-000000@amazonses.com
Received: from a9-36.smtp-out.amazonses.com (a9-36.smtp-out.amazonses.com. [54.240.9.36])
        by mx.google.com with ESMTPS id w12si3497914qth.106.2019.02.21.10.47.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 21 Feb 2019 10:47:24 -0800 (PST)
Received-SPF: pass (google.com: domain of 0100016911623854-e69813aa-5820-4a46-a5d8-eb2943a83056-000000@amazonses.com designates 54.240.9.36 as permitted sender) client-ip=54.240.9.36;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=GUcJJ46s;
       spf=pass (google.com: domain of 0100016911623854-e69813aa-5820-4a46-a5d8-eb2943a83056-000000@amazonses.com designates 54.240.9.36 as permitted sender) smtp.mailfrom=0100016911623854-e69813aa-5820-4a46-a5d8-eb2943a83056-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1550774843;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=dDOoo//97jtf2YhpPK55rtG27CPC1ox36HVpRSVj0ms=;
	b=GUcJJ46sPjpHOsss4KxAWPQmkMdv/c92MHUnB00z3OPPwh+yQuuFH1WDzchxCq/2
	SvxKLLAQx8w0qR6nlNk9tX8cAu+rGCY0EUaIX9A/Nys8SyieaBqLgcH8q0XEoeQWZuV
	e+ssMWYTrMj0jOpKDCLCEqi73gTHGPIjsH4R3AwI=
Date: Thu, 21 Feb 2019 18:47:23 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Rik van Riel <riel@surriel.com>
cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, 
    lsf-pc@lists.linux-foundation.org
Subject: Re: [Lsf-pc] Memory management facing a 400Gpbs network link
In-Reply-To: <3057d2336e88897309756a9c0e10727856589965.camel@surriel.com>
Message-ID: <0100016911623854-e69813aa-5820-4a46-a5d8-eb2943a83056-000000@email.amazonses.com>
References: <01000168e2f54113-485312aa-7e08-4963-af92-803f8c7d21e6-000000@email.amazonses.com> <20190219122609.GN4525@dhcp22.suse.cz> <01000169062262ea-777bfd38-e0f9-4e9c-806f-1c64e507ea2c-000000@email.amazonses.com> <20190219173622.GQ4525@dhcp22.suse.cz>
 <0100016906fdc80b-4471de43-3f22-45ec-8f77-f2ff1b76d9fe-000000@email.amazonses.com> <20190219191325.GS4525@dhcp22.suse.cz> <0100016907829c4c-7593c8e2-1e01-4be4-8eec-a8aa3de00c18-000000@email.amazonses.com> <20190220083157.GV4525@dhcp22.suse.cz>
 <010001691144c94b-c935fd1d-9c90-40a5-9763-2c05ef0df7f4-000000@email.amazonses.com> <3057d2336e88897309756a9c0e10727856589965.camel@surriel.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.21-54.240.9.36
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Feb 2019, Rik van Riel wrote:

> On Thu, 2019-02-21 at 18:15 +0000, Christopher Lameter wrote:
>
> > B) Provide fast memory in the NIC
> >
> >    Since the NIC is at capacity limits when it comes to pushing data
> >    from the NIC into memory the obvious solution is to not go to main
> >    memory but provide faster on NIC memory that can then be accessed
> >    from the host as needed. Now the applications creates I/O
> > bottlenecks
> >    when accessing their data or they need to implement complicated
> >    transfer mechanisms to retrieve and store data onto the NIC
> > memory.
>
> Don't Intel and AMD both have High Bandwidth Memory
> available?

Well that is another problem that I omitted from the new revision.

Yes but that memory is special with different performance characteristics
and often also represented as another NUMA node.

> Is it possible to place your network buffer in HBM,
> and process the data from there?

Ok but there is still the I/O bottleneck. So you can either have the HBM
on the host processor (Xeon Phi solution) in a special NUMA node. Or you
put the HBM onto the NIC and address it via PCI-E from the host processor
(which means slower access for the host but fast writes from the network)

