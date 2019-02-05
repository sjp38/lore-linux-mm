Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5442C282CC
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 21:56:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F3842077B
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 21:56:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="OO0ZZE3q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F3842077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1FC798E00A0; Tue,  5 Feb 2019 16:56:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 183328E009C; Tue,  5 Feb 2019 16:56:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0249E8E00A0; Tue,  5 Feb 2019 16:56:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id C2D618E009C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 16:56:01 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id p20so3314298ywe.5
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 13:56:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=wMhcdXCHqf6V6KTLtjLRAAlffUFv2sOj48RQqhjWWzg=;
        b=p5MQX9xAzIMun65LnMEUSoo6uWX6OGP8wxuXqT0C7LFUmUFtOlF4hkMirfDzzxZElS
         r6La/Iw8p4w3HViyS+4cHOWFx9CYPiyB4U0j+qdDIXWMVXSUXPbn+c9OTiU2XDPkfEj2
         cbHG0Dow4urhDV5IkV3k4pbJ6Jfgo/faT2eUj27UWm5Rn05qSBPZ9RYDVLpTYyXAS4A2
         IHa+bXwZw3xGEgz0w7HVkV+A4ac+9fqggohG8Salxs8cQmY0b0pMkKKDrVAI72hTNMp1
         Jvd6veLf+WMR8aMukE8+6C+PpgGs0ENhTOKTbBtgxTP9l8bbRtWWDvcbsGzpzb+FpCYq
         EDDg==
X-Gm-Message-State: AHQUAuYaCZQNb2PQNRaErVYAf4IsT4suDMw3wglE/OVaAu9pHUIpYDVH
	WJ3NicU0tQTSNJ6WdM1NWYCt7ZlXIktRLmJbc7utcKFvWDy2bVRp7fDBOTzew/1uOHNzAFjiMKI
	KZd7DpD9Bb8GyO7qDev+6O5IoNPT2dKW56XdpLL2w0LEGBQ6QDe0vEe+mAupQpT/gDw==
X-Received: by 2002:a81:f00c:: with SMTP id p12mr2867214ywm.242.1549403761520;
        Tue, 05 Feb 2019 13:56:01 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZe5SK+XSfS0D2+HtvHapUafaNl/BxWzjC2MoRqqRLNLYV+B598ScfZImP8ykGxjfCeLXjb
X-Received: by 2002:a81:f00c:: with SMTP id p12mr2867185ywm.242.1549403760913;
        Tue, 05 Feb 2019 13:56:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549403760; cv=none;
        d=google.com; s=arc-20160816;
        b=oaVzrri6YrtO7u2HA7Y+B/swUTbrFihnV2WZHw9Ly7JI4tOoAh91Le8+g9VvZfFu04
         d1l3/MSETeoNiJojU2MCuamRHwzy5JQ0B/7LRC5sMy/U0W6eeHC23vp/4UYFlmlOL/Xq
         w7zxkY46cWLczWUzd8fUOo7tgbJnpxgwfWMvum3Xa6lWmC7N3KR1iHm7gqLqjpLKsPzG
         vvXOYjHI1ExEquzYmv19dv+i1/sdAmA2t3MRC/LFDDwK0/uwEmTJMarcLoxrmhGq6mzz
         xoGRGOTECx9B3eOvGqjcHQOsYJ+8w1BH0+z0iz/8bibVy2cBnKb3eK7Wz+cAbwrLkyK1
         XpDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=wMhcdXCHqf6V6KTLtjLRAAlffUFv2sOj48RQqhjWWzg=;
        b=L+jYThUGtTj+FZ6/1/ZlN5fvlz904wxhgTKio0l/pqZ312PAoX3Q2UN/ZnuWa3XJyU
         1Tn8A2zJnyT0kg/zeuTzbZGm3ZvdKiGSFbwBEy3PkFGYV4hgapzjQVyuGLn/hM9mhJ65
         57jLSRFFlD3D0edGnPio5XazdvcaBTlS8KGTh4xT3YlhYK2QbICOch7eolBvtfmzbip4
         N5/oCkD6/KzS58GA+2iY6PyaEAaT+G+8qYlA0YGV5MrvR/TdxX+WqzPHQN7HLrl/gQyO
         9ESsPA/cmdk/slzb66HSkXAAajSAQK/WFH29Y0pg9cf2vfDvcqCH1MvyM6QrEInfs+TD
         ++MQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=OO0ZZE3q;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id s4si2690111ywf.128.2019.02.05.13.56.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 13:56:00 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=OO0ZZE3q;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c5a06500000>; Tue, 05 Feb 2019 13:55:28 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Tue, 05 Feb 2019 13:56:00 -0800
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Tue, 05 Feb 2019 13:56:00 -0800
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Tue, 5 Feb
 2019 21:55:59 +0000
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
 <80d503f5-038b-7f0b-90d5-e5b9537ae1df@nvidia.com>
 <303ab506-62b7-ee6d-27a0-a818c7ff6473@talpey.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <e2bac0b5-f81f-c2f1-95eb-214c64e89ee0@nvidia.com>
Date: Tue, 5 Feb 2019 13:55:59 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <303ab506-62b7-ee6d-27a0-a818c7ff6473@talpey.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1549403729; bh=wMhcdXCHqf6V6KTLtjLRAAlffUFv2sOj48RQqhjWWzg=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=OO0ZZE3qlHVf7SLdzkvxMWo8XPxxiTP0f0GbZjWPp4EwFzG8T3wH/G90QrC6UY+cr
	 JCi0vR8kO1CQ3Zdhp4G2h1lQf45kXjhbwe5mTO4TNxbZE0we2A/YGY3MMqhK/nrdEE
	 eyAjKEEabxwN341c/4qSWtvue/sbKfSrwdWIgLYquHT71qrxziTp4K0ntquXnOw2ZM
	 5eWdd0BVHj9lyakmUVr4gl3zoIcsDVAX62yvqMpjjBJaMPrL1mTJCPZD9NwZ1X3Tbq
	 yEDowBywN1BKTGq6Ewl5ClbhZ+Scn8ItHzjdc4m6fYhwAqBSq171mOvpyyauKHBgmU
	 ohRJzyuCO5GNg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/5/19 5:38 AM, Tom Talpey wrote:
> 
> Ok, I'm satisfied the four-9's latency spike is in not your code. :-)
> Results look good relative to baseline. Thanks for doublechecking!
> 
> Tom.


Great, in that case, I'll put the new before-and-after results in the next 
version. Appreciate your help here, as always!

thanks,
-- 
John Hubbard
NVIDIA

