Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A899C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 01:37:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1203E20675
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 01:37:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="SIPQduyb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1203E20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BC3D8E0004; Tue,  5 Mar 2019 20:37:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 741F38E0001; Tue,  5 Mar 2019 20:37:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E3528E0004; Tue,  5 Mar 2019 20:37:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 180158E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 20:37:21 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id e5so10571353pgc.16
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 17:37:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:references:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=6G8GEDfxvsgo3WrgfYipOKCdt+hHrNFO1Dj0Plwre1c=;
        b=CpDLz9eT2hGLK96+mH1rTJ7Y2fS1GNr5/XG/bq8ZD5mfPEZSjNw4b/ChLf5+/EX16E
         zHLEtj85eIxXzdDKP72j0jbeVOAzN5EzBSpOujymlOgNqx94aqKaxO0cymKaO8V419GB
         oTxvRgQETn6IvtvQDluhJmN4T3s7S2GchTlFBmwGdiDogpbhsJYz0vwIyA4ufgyLzber
         5tpoAMaAi+U4OWShPLFky+UzeQ/B8r6DybqiUgg6BHEjysvQ7QbNXuNgnkO5dzrEFmU2
         wHs4SVocacauKM0dZCZZUnLILsC5zMjI3g3p23utrP1EYKv64KzSeX702M0hp+twqnht
         peMQ==
X-Gm-Message-State: APjAAAXozyBwTZzR4L6OC+xEQ2aOgdvSZKetleH4654OFgFe6IwQLutP
	SNoX/7dNmKR6hJzT+bNrxOMdHD1n+NpouvdF2vCp3GsABgPMg8cgITXC/wC+GewRsEMJONFygab
	qWZ5p0SX/BU3Az96l2C0eyYFc7NypnCvH4jcbbxFKOzhS8zL6zczh6Ija0uVKMoAiIQ==
X-Received: by 2002:a17:902:1105:: with SMTP id d5mr4335225pla.27.1551836240722;
        Tue, 05 Mar 2019 17:37:20 -0800 (PST)
X-Google-Smtp-Source: APXvYqxJb8XdMoQD40gUVoIFYsJEUJnQ8ELaSb9ee/Y6XVQYCe5rdDXwKct3nV9Ne8wiWYThxAU/
X-Received: by 2002:a17:902:1105:: with SMTP id d5mr4335164pla.27.1551836239891;
        Tue, 05 Mar 2019 17:37:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551836239; cv=none;
        d=google.com; s=arc-20160816;
        b=hdsKMnYropLZjtFf9tVb8c84LOo/9fZh3tz/sSVPSW2U9zWnzRm6zjYs1BA2ZHVZLF
         DOK8RiCjhM2KV3YXCeTSE91bWimOZtun+sWbRAN81EN+wLMmljsNxK38pirunK9X4P0E
         EP4SGKjBan4Ccf4QvgfM8+qNB9QH1v+brSGpnn9UEcOS1F2OeqYOJ3Ih+5PJgsULlao8
         IJcqn/2s30O33T70N3fJvb+b3qiaH1BIlgY/3klU8ca1XPOJFOHFp6ri7NJ2eZHfYQ7R
         zzI9htmCwIC08OvBR+/dqDOSsR5ADuNM6+S4mlXPjbFwi6efeOQHulqVRXA+8BaCG9bu
         BMJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:references:cc
         :to:from:subject;
        bh=6G8GEDfxvsgo3WrgfYipOKCdt+hHrNFO1Dj0Plwre1c=;
        b=z2rN838hJEZY1nep2IH/0qRNDarwOjmZ1cSXmQk1Ffgwjzk0NWqhUC7+COokKaXAO+
         qo0FzP1D9DPgqJMpzDdyuBShO13tS7kS5YrfyqaaZB9A6LfGb/rTb1o+JkyY5NsMNwaT
         RVAXls3YK7OPhyMxASxARNeOxChqvHY7BkZ8dP5d2W9uGZ5voTH+fk3r7IC9rgAUgkWb
         I8hWaTVXFV2oSMFQpGazI2b6jXztAO3t/h4lpCX9Dw37C4Wcn+bq95bJ6kI8FAQ6l1PJ
         DOAfvMM6bAh7wNajqdbdxcrJTsoY2jFV7Ht7tKImLJPacYj8IXrmAcV5+DwFN8BgtWFb
         PCcg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=SIPQduyb;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id k70si257574pgd.74.2019.03.05.17.37.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Mar 2019 17:37:19 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=SIPQduyb;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c7f24470000>; Tue, 05 Mar 2019 17:37:11 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 05 Mar 2019 17:37:19 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 05 Mar 2019 17:37:19 -0800
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 6 Mar
 2019 01:37:19 +0000
Subject: Re: [PATCH v2] RDMA/umem: minor bug fix and cleanup in error handling
 paths
From: John Hubbard <jhubbard@nvidia.com>
To: Jason Gunthorpe <jgg@ziepe.ca>, Artemy Kovalyov <artemyko@mellanox.com>
CC: Ira Weiny <ira.weiny@intel.com>, "john.hubbard@gmail.com"
	<john.hubbard@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew
 Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Doug
 Ledford <dledford@redhat.com>, "linux-rdma@vger.kernel.org"
	<linux-rdma@vger.kernel.org>
References: <20190302032726.11769-2-jhubbard@nvidia.com>
 <20190302202435.31889-1-jhubbard@nvidia.com>
 <20190302194402.GA24732@iweiny-DESK2.sc.intel.com>
 <2404c962-8f6d-1f6d-0055-eb82864ca7fc@mellanox.com>
 <332021c5-ab72-d54f-85c8-b2b12b76daed@nvidia.com>
 <903383a6-f2c9-4a69-83c0-9be9c052d4be@mellanox.com>
 <20190306013213.GA1662@ziepe.ca>
 <74f196a1-bd27-2e94-2f9f-0cf657eb0c91@nvidia.com>
Message-ID: <be6303c6-d8d2-483a-5271-b6707c21178e@nvidia.com>
Date: Tue, 5 Mar 2019 17:37:18 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <74f196a1-bd27-2e94-2f9f-0cf657eb0c91@nvidia.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1551836231; bh=6G8GEDfxvsgo3WrgfYipOKCdt+hHrNFO1Dj0Plwre1c=;
	h=X-PGP-Universal:Subject:From:To:CC:References:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=SIPQduyblHaTorJ/IxfQwnvaVrKpUl86in8rp1GvHjeawW6d/PlJADuzgrfnghvLg
	 MCXDaK+fT3LTD4dfvHQj5Zp58z5l062wGLsZcBQ+RNqujk7pOx+L57REJhXq12dIYJ
	 NluAX4zHKHfZfYbr1WwyEmfNPiPgESRb7WcLrEYPCVioLUyxSqUsLguTfeAAGrPJTe
	 2Ks4Afx352OHuL9+u1LAYI78zfhnJrTowstYdLqxHfXO2MUK7m4pBkg5RSclhw/Smg
	 BP/I/YB/Lh/P9eylMPG5H3ayxZOtHAtZ5bYkbzryZQ6uFZhjE8QYblJ3xWUJadLFdc
	 sPfem+gunPxoQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/5/19 5:34 PM, John Hubbard wrote:
[snip]
>>> So release_pages(&local_page_list[j+1], npages - j-1) would be correct.
>>
>> Someone send a fixup patch please...
>>
>> Jason
> 
> Yeah, I'm on it. Just need to double-check that this is the case. But Jason,
> you're confirming it already, so that helps too.
> 
> Patch coming shortly.
> 

Jason, btw, do you prefer a patch that fixes the previous one, or a new 
patch that stands alone? (I'm not sure how this tree is maintained, exactly.)

thanks,
-- 
John Hubbard
NVIDIA

