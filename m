Return-Path: <SRS0=vc3H=PU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8951AC43387
	for <linux-mm@archiver.kernel.org>; Sat, 12 Jan 2019 20:46:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43D7E2084C
	for <linux-mm@archiver.kernel.org>; Sat, 12 Jan 2019 20:46:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="B6mdTEc8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43D7E2084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D8CB38E0003; Sat, 12 Jan 2019 15:46:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D3E388E0002; Sat, 12 Jan 2019 15:46:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C04348E0003; Sat, 12 Jan 2019 15:46:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 901D08E0002
	for <linux-mm@kvack.org>; Sat, 12 Jan 2019 15:46:23 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id b8so9836581ywb.17
        for <linux-mm@kvack.org>; Sat, 12 Jan 2019 12:46:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=S5Ve03vaCXwHxIylHrHXTXq61SQp1ualr/VOmbbPK4M=;
        b=d9dpWgqLC6PGfVLDXr6SiQmC3FvEjI5PahS2J12ulZOas70GD1M0YtFdzZkwhrVu1V
         De1ziw8aVgybgZvxJ5bVBGLCRgbCQBOBR5+cTgeGYNNnLQUEyZOV4ZZVWn55fErRzsRV
         ltSmlMXxUSRmub7e6RSizCfTj86D+B+i95ePIIoYazMW5dxQ/t55Oxd81uVFP4VrHfY8
         pC0CDUQoujZGs6iK7NFkqd1OhR6grO6sM3MAQCed5R3QtyERrU3O4/madO8hkXsCpMi7
         pzl68YKOH9fTWkUCHy0zqMosmlL7dHLpfEOHA11HbiNjvkp+/UwS9U54iUC33eXrBAws
         L57A==
X-Gm-Message-State: AJcUukeCg0fBumkeIBAcmB5+R5qTrN34uum5g+gcJ9p11iLHJfyOH87T
	1Hsd7oMz+davtpo6T55UoZSsJ9+3QP4sM+Zky4J5dr4dnTnO+bJoi/Dy3RiSd6MGHoZF5EDL2wG
	uWncyq8la5AyQbMtYW+yTc9u5ZjmiSGe/7mYZ8KC1j1ku64TaMAG4exRlMKoqrJUmAg==
X-Received: by 2002:a25:3f46:: with SMTP id m67mr17873389yba.476.1547325983217;
        Sat, 12 Jan 2019 12:46:23 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7Y8vtmW8qgJKdO+DVdcG2K5OvKnAbMWV8K7VmlmOuw+ijPNQ9/6I4fWdgOctbgQCctmjJW
X-Received: by 2002:a25:3f46:: with SMTP id m67mr17873370yba.476.1547325982541;
        Sat, 12 Jan 2019 12:46:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547325982; cv=none;
        d=google.com; s=arc-20160816;
        b=L4Fyh0xB/UhPxV6uSKyO2JxkWY9okYWPdHBNavYcPczPVsFTz6sX6yRwZn1uXinS0J
         S8S7zS73DXZT6134rT7+MxP98eXktWYh0h8Pt4UJ6QH+9vTlXfx807mikuaGZ76D+S35
         yf3ljX30dmUITCh5HjOZdUN09zVj/42WMOL1WUdKZhqXjgc8pA99UrZRGH53K2P9uZCA
         ZAyyvMj8V0r5D1//2p069yHPToXIuSOAJLroouPAHHIipvIwpfXb6Ed13FRwdXhOERk+
         aDBCXQ6TAVsxpY1/zQ2FTe8hrNRGzHqgfYarOybL+y+AsEs/P+F10vNVNXmBqBzaceN6
         PZTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=S5Ve03vaCXwHxIylHrHXTXq61SQp1ualr/VOmbbPK4M=;
        b=sgK6EI/dtBnitCfYCukag50y9PMY3kSJ+kvNXndshq4cenjSitmElslIMC1tx88JVj
         Ff+vzQPwGUMflzohrcIYNCRczgbxjkG7UkCa+NyO87fNmB5uNSXKq7sNLw2SlyIl0HwK
         +LtpBO4z55w4BAuJ/wd//jrxuYR7ybb6jgE40yLfcqsb25CUA+HYHUHD2zKV/VVvXL+E
         V16Loi/8oyulJU5duM0gG3ew1lAfCEWvN+4Jp0xoz5cEf5SBGy76k9za7uvRCPsa1NC7
         BU6ymlCi5ANtCX/2/MiF0N+apQQmMmMbsLp1o92rR6nFFlaPbYTxudr79yl+YVoRLzUH
         mr0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=B6mdTEc8;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id f65si49185101ywe.66.2019.01.12.12.46.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 12 Jan 2019 12:46:22 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=B6mdTEc8;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c3a520f0000>; Sat, 12 Jan 2019 12:46:07 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Sat, 12 Jan 2019 12:46:21 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Sat, 12 Jan 2019 12:46:21 -0800
Received: from HQMAIL102.nvidia.com (172.18.146.10) by HQMAIL103.nvidia.com
 (172.20.187.11) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Sat, 12 Jan
 2019 20:46:20 +0000
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL102.nvidia.com
 (172.18.146.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Sat, 12 Jan
 2019 20:46:21 +0000
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
To: Jerome Glisse <jglisse@redhat.com>
CC: Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, "Dave
 Chinner" <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>,
	"John Hubbard" <john.hubbard@gmail.com>, Andrew Morton
	<akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, <tom@talpey.com>,
	Al Viro <viro@zeniv.linux.org.uk>, <benve@cisco.com>, Christoph Hellwig
	<hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro,
 Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>,
	Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>,
	<mike.marciniszyn@intel.com>, <rcampbell@nvidia.com>, "Linux Kernel Mailing
 List" <linux-kernel@vger.kernel.org>, linux-fsdevel
	<linux-fsdevel@vger.kernel.org>
References: <20190103015533.GA15619@redhat.com>
 <20190103092654.GA31370@quack2.suse.cz> <20190103144405.GC3395@redhat.com>
 <a79b259b-3982-b271-025a-0656f70506f4@nvidia.com>
 <20190111165141.GB3190@redhat.com>
 <1b37061c-5598-1b02-2983-80003f1c71f2@nvidia.com>
 <20190112020228.GA5059@redhat.com>
 <294bdcfa-5bf9-9c09-9d43-875e8375e264@nvidia.com>
 <20190112024625.GB5059@redhat.com>
 <b6f4ed36-fc8d-1f9b-8c74-b12f61d496ae@nvidia.com>
 <20190112032533.GD5059@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <9c80b708-35fa-3264-f114-b4d568939437@nvidia.com>
Date: Sat, 12 Jan 2019 12:46:20 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190112032533.GD5059@redhat.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL102.nvidia.com (172.18.146.10)
Content-Type: text/plain; charset="UTF-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1547325967; bh=S5Ve03vaCXwHxIylHrHXTXq61SQp1ualr/VOmbbPK4M=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=B6mdTEc8J4L+vxmPnvh2LMfZg62OITAz3mtChLxLDlNlNg/ULoNQEQKSGyJogwPYI
	 atHUfrgDu36CWs02kKFr3ogRiYUm5g5XM82JRt+BS9LVW27aCh0Bz5QrzmkJAUukTM
	 Nk9zhsXdbcZcNII2w1Oq24yK5PXnph07smMyZ/Ifvf2w0VoRJJs+8YWBHZ9n1IH1RU
	 iYeY+U0lhdSbBXXUUIkuyrjrwdS7+YAstGQflcQgTqtapsQuAWE0cAUgLjVD8ZXKfZ
	 X38BO8N+KDa0aQvHwFPHmYH+boWy5Ea1lFXjPritx/gmXyZ/uB4ooMnkTzXn60iRhM
	 4/yj0MtS91d7Q==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190112204620.vZf_wMG2-BhcEjZUsjAqYWO2tvfXNJuFnYHWEPEhvJE@z>

On 1/11/19 7:25 PM, Jerome Glisse wrote:
[...]
>>>> Why is it that page lock cannot be used for gup fast, btw?
>>>
>>> Well it can not happen within the preempt disable section. But after
>>> as a post pass before GUP_fast return and after reenabling preempt then
>>> it is fine like it would be for regular GUP. But locking page for GUP
>>> is also likely to slow down some workload (with direct-IO).
>>>
>>
>> Right, and so to crux of the matter: taking an uncontended page lock involves
>> pretty much the same set of operations that your approach does. (If gup ends up
>> contended with the page lock for other reasons than these paths, that seems
>> surprising.) I'd expect very similar performance.
>>
>> But the page lock approach leads to really dramatically simpler code (and code
>> reviews, let's not forget). Any objection to my going that direction, and keeping
>> this idea as a Plan B? I think the next step will be, once again, to gather some
>> performance metrics, so maybe that will help us decide.
> 
> They are already work load that suffer from the page lock so adding more
> code that need it will only worsen those situations. I guess i will do a
> patchset with my solution as it is definitly lighter weight that having to
> take the page lock.
> 

Hi Jerome,

I expect that you're right, and in any case, having you code up the new 
synchronization parts is probably a smart idea--you understand it best. To avoid
duplicating work, may I propose these steps:

1. I'll post a new RFC, using your mapcount idea, but with a minor variation: 
using the page lock to synchronize gup() and page_mkclean(). 

   a) I'll also include a github path that has enough gup callsite conversions
   done, to allow performance testing. 

   b) And also, you and others have provided a lot of information that I want to
   turn into nice neat comments and documentation.

2. Then your proposed synchronization system would only need to replace probably
one or two of the patches, instead of duplicating the whole patchset. I dread
having two large, overlapping patchsets competing, and hope we can avoid that mess.

3. We can run performance tests on both approaches, hopefully finding some test
cases that will highlight whether page lock is a noticeable problem here.

Or, the other thing that could happen is someone will jump in here and NAK anything
involving the page lock, based on long experience, and we'll just go straight to
your scheme anyway.  I'm sorta expecting that any minute now. :)

thanks,
-- 
John Hubbard
NVIDIA

