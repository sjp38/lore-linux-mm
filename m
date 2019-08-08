Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83497C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 18:18:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3340621743
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 18:18:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="Ne1ScLdQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3340621743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D8A4F6B0006; Thu,  8 Aug 2019 14:18:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D131C6B0007; Thu,  8 Aug 2019 14:18:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BDB196B0008; Thu,  8 Aug 2019 14:18:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 880E16B0006
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 14:18:52 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id g18so55923787plj.19
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 11:18:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=JXH0z+PATu5ChINAttu0xw8NI7VYrjVhdTogRmB3Q5s=;
        b=o8nR9iX39tQAZuZVsz2T6l8YFlU8x5dW1gPRK88lq559wui1h+xPA+6gE1Ge3iG9ut
         WEiWsqOt1hr9qIobvQYdfIINEq+99cfQyGvgBL3dSCJ2ClAslm2xrdNXMP+C+Tm4xlO+
         Rscj63011Ds5ktemdRMs8RkxUOhDiwtLPPpruvtalV3Nhwwwlu1eL+Vw4b2lzJ4RE2qa
         tv3YauONsEYWYIo0Nq86bKgBX61rLpJFczd3v603WkltfHuuYD2kk3zzRfO8qSj++PPU
         Gfrt53m4IkjNvIs4LqgBWTQ0phSqscaCWRUjykApAGXOoZAFC2Ew8v2jex0JCP4Poenr
         UyxA==
X-Gm-Message-State: APjAAAX/pxeDkeyXze4icchESHM42mzc03Tarcq/bdBbapBlpC2CyWl4
	ELMpuZ/14y3z3rFGy8ARFKmifeX4xswQXyyDnmB//xFT+bQMLPAW7lfMuyu8pY/Rp9PIv0FKlXK
	Dtfj8j8c1qA8CtunAAAa/5xcZwULEedtyqj7r9OzcvI3dV3BjrrQRVO2OEg3Jkg3HCg==
X-Received: by 2002:a63:1b66:: with SMTP id b38mr13994740pgm.54.1565288332052;
        Thu, 08 Aug 2019 11:18:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynMz7SIEHcLlh/k7Uy146GQz8jlmvkgtgtKz9UXDAeoiY9LoTDZJ0a20t0j80YDbwHv7S0
X-Received: by 2002:a63:1b66:: with SMTP id b38mr13994706pgm.54.1565288331205;
        Thu, 08 Aug 2019 11:18:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565288331; cv=none;
        d=google.com; s=arc-20160816;
        b=ZP8MS6yTq9VZJ6k4dIdZWOpmj/S40I0C6pQqeDAea7dH6OF8es1BQO3jxgOwkDjeKN
         AolcRpsLnJg+v0WYYtjkTOmZKZcgXyO+/ETxlm9Cy50X9DwdIt2y2ESyvYSg763VPGGn
         7IiBHr6Omq7AqG9ghg7374nnirXFmsrUZ8CpenPGiTUjh8fn0z42mJqhw3YuxrmMN3Kk
         aqrmbqjqAA/viOdPkyDC3v7U4mt5NnkSLAWescoZREaNwKIimNXrhSTzVFTa9nuyPmAZ
         4237V4Fywvczjr3K0USi8iMpppWqwxIWLit+Xqwmshv3icBwN9o3r8x0g10QO0DsmZBo
         E85w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=JXH0z+PATu5ChINAttu0xw8NI7VYrjVhdTogRmB3Q5s=;
        b=aDpsmG48/efKFD3Q2gqYuVByja246yXme8AxWMN1hb6Rezeq+UXyCBTQpn9txm9Z+m
         hWoajxwraJO/BF8DuTl6y/z/suI5poeTo/os5JXaQR+3vGGhoaOzyAadTBhe5WyzSk8+
         WufM920piS0P1RgczwPZTSOUKbibjXRHECk7bpnuiOIwS+nQ0hYKzikdk+FjtuvmpuYj
         oDEPQlB/IPONJ2BqYIPBsVm8e1kjNmYU686VKCjn95f1lilcB9k4WkUKCU5UdXpnmihb
         gKRupCBAT/5ZVso3yWVtm5sGj1awGgqkDD9NXNTdMgIrxLL1efsNMplsus0OMe8TQtxE
         iipQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Ne1ScLdQ;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id b22si19354247pgw.298.2019.08.08.11.18.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 11:18:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Ne1ScLdQ;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d4c678b0000>; Thu, 08 Aug 2019 11:18:52 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Thu, 08 Aug 2019 11:18:50 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Thu, 08 Aug 2019 11:18:50 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 8 Aug
 2019 18:18:49 +0000
Subject: Re: [PATCH 00/34] put_user_pages(): miscellaneous call sites
To: "Weiny, Ira" <ira.weiny@intel.com>, Michal Hocko <mhocko@kernel.org>
CC: Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Andrew
 Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>,
	"Williams, Dan J" <dan.j.williams@intel.com>, Dave Chinner
	<david@fromorbit.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jason
 Gunthorpe <jgg@ziepe.ca>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, LKML <linux-kernel@vger.kernel.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"ceph-devel@vger.kernel.org" <ceph-devel@vger.kernel.org>,
	"devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
	"devel@lists.orangefs.org" <devel@lists.orangefs.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"intel-gfx@lists.freedesktop.org" <intel-gfx@lists.freedesktop.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-block@vger.kernel.org"
	<linux-block@vger.kernel.org>, "linux-crypto@vger.kernel.org"
	<linux-crypto@vger.kernel.org>, "linux-fbdev@vger.kernel.org"
	<linux-fbdev@vger.kernel.org>, "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>, "linux-media@vger.kernel.org"
	<linux-media@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-rpi-kernel@lists.infradead.org"
	<linux-rpi-kernel@lists.infradead.org>, "linux-xfs@vger.kernel.org"
	<linux-xfs@vger.kernel.org>, "netdev@vger.kernel.org"
	<netdev@vger.kernel.org>, "rds-devel@oss.oracle.com"
	<rds-devel@oss.oracle.com>, "sparclinux@vger.kernel.org"
	<sparclinux@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
 <20190802091244.GD6461@dhcp22.suse.cz>
 <20190802124146.GL25064@quack2.suse.cz>
 <20190802142443.GB5597@bombadil.infradead.org>
 <20190802145227.GQ25064@quack2.suse.cz>
 <076e7826-67a5-4829-aae2-2b90f302cebd@nvidia.com>
 <20190807083726.GA14658@quack2.suse.cz>
 <20190807084649.GQ11812@dhcp22.suse.cz>
 <20190808023637.GA1508@iweiny-DESK2.sc.intel.com>
 <e648a7f3-6a1b-c9ea-1121-7ab69b6b173d@nvidia.com>
 <2807E5FD2F6FDA4886F6618EAC48510E79E79644@CRSMSX101.amr.corp.intel.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <b1b33292-d929-f9ff-dd75-02828228f35e@nvidia.com>
Date: Thu, 8 Aug 2019 11:18:49 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <2807E5FD2F6FDA4886F6618EAC48510E79E79644@CRSMSX101.amr.corp.intel.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565288332; bh=JXH0z+PATu5ChINAttu0xw8NI7VYrjVhdTogRmB3Q5s=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=Ne1ScLdQ+tu5qOaISiLlk/MzD+D0tWGCUEcW8KATp/99KORz80qhTvSS0MA86k71v
	 1gG74XZNfpVRbFXyQsXs+wV66Ly/i7Omeym8buU22OwtUh/B674iBCJPOoXFe5hxmV
	 1e7OUBsDbdwXkl/h4Pjx1eOWT4qAVANZ24jESe93raeMkGLORABLpzcfJ+l/YUvFr/
	 bUBCYBUk9JXLyxcXRRJ6Qo5DLPNTbuOY1/JVx8JLOWf78tx+O5w4P2ZxYGmo4q53CG
	 aum+FjJWUhUsxhssDMyUyjXEHRPMBfcGtXYtpdJqmbhfodN4x0QDM6mw3fwyew2GF4
	 p5OXETBP5SbRg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/8/19 9:25 AM, Weiny, Ira wrote:
>>
>> On 8/7/19 7:36 PM, Ira Weiny wrote:
>>> On Wed, Aug 07, 2019 at 10:46:49AM +0200, Michal Hocko wrote:
>>>> On Wed 07-08-19 10:37:26, Jan Kara wrote:
>>>>> On Fri 02-08-19 12:14:09, John Hubbard wrote:
>>>>>> On 8/2/19 7:52 AM, Jan Kara wrote:
>>>>>>> On Fri 02-08-19 07:24:43, Matthew Wilcox wrote:
>>>>>>>> On Fri, Aug 02, 2019 at 02:41:46PM +0200, Jan Kara wrote:
>>>>>>>>> On Fri 02-08-19 11:12:44, Michal Hocko wrote:
>>>>>>>>>> On Thu 01-08-19 19:19:31, john.hubbard@gmail.com wrote:
>>   [...]
> Yep I can do this.  I did not realize that Andrew had accepted any of this work.  I'll check out his tree.  But I don't think he is going to accept this series through his tree.  So what is the ETA on that landing in Linus' tree?
> 

I'd expect it to go into 5.4, according to my understanding of how
the release cycles are arranged.


> To that point I'm still not sure who would take all this as I am now touching mm, procfs, rdma, ext4, and xfs.
> 
> I just thought I would chime in with my progress because I'm to a point where things are working and so I can submit the code but I'm not sure what I can/should depend on landing...  Also, now that 0day has run overnight it has found issues with this rebase so I need to clean those up...  Perhaps I will base on Andrew's tree prior to doing that...

I'm certainly not the right person to answer, but in spite of that, I'd think
Andrew's tree is a reasonable place for it. Sort of.

thanks,
-- 
John Hubbard
NVIDIA

