Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C045BC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 00:54:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61F2621934
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 00:54:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="m8rpA8Tx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61F2621934
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91B688E0002; Thu, 14 Feb 2019 19:54:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8CB428E0001; Thu, 14 Feb 2019 19:54:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B90A8E0002; Thu, 14 Feb 2019 19:54:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4CEA88E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 19:54:28 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id t17so4838346ywc.23
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 16:54:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=OHV4QGJwXMt6cTDDR9gAJliF74InHPXXIremhlCNuPU=;
        b=MWtbrfp+utGZWnxC0V2fPQ7ibWXBZgs5TebAiFqVUYoZ/aiK/+gszl9Zmsw3JMuYhE
         7+UkBIvsoB7yilVVesQF2dm5hh715PZiy9TJpmb5ix97JhZsGduF2/Ea82U5C97lD6qr
         iR+Sl05CaDWm1eJBcfcN5yqohhP6HXFtHXmsihpLnl5V2ZsrzDv2EZzPXUuARbyYUhUq
         tvDi4Oh5pRnAvtl1sd7okRF2FPTDAdcZOO62gnnJo0EbSD+CJJMyIhqJtsqdvy20Fzxy
         65xkDes9Ap/4eNw3TTWUDA13ECpBWiSY28vlYqG2Ud1N32M2cZqLgag7IkwDPQDACoba
         jjXg==
X-Gm-Message-State: AHQUAuZkVJzM4DvCFnakNH5PvwRZanjBSfgOatjX+lMAnWrH5e2V7Q+L
	of/KbgQtEi32y1SYG8dTJRNAVMJzvRnR5N1URZIvIzb4XkKTTLWqGf1OLas/WtoHgs1o3mGFWXZ
	M1umS+LtF/p6OR9KksZuoXYJin+051m2lJNpMCYerDdn7NRbieGbuW3JdmwZyVRRCCg==
X-Received: by 2002:a0d:cc46:: with SMTP id o67mr5904970ywd.123.1550192068021;
        Thu, 14 Feb 2019 16:54:28 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY7ghHuhH6wJw9HpLt+0vnjQkI/7J+T6HO7iWJFOnfwgmXGNA5Dg3ha+wdjQ56cKF2WjG1J
X-Received: by 2002:a0d:cc46:: with SMTP id o67mr5904950ywd.123.1550192067416;
        Thu, 14 Feb 2019 16:54:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550192067; cv=none;
        d=google.com; s=arc-20160816;
        b=WCyIf2f71mdDYnj9aaRPI7NeQk8IpAkS17Rqtw7eXtzIAY+mPzm+N2BFGT+FKca0+i
         6W9AWOzNomvQeg0oDfKE9jqevKqmMy0kRhnkkTOn3YBkCLFWifXK65GP2dE5HQVpo5rW
         nj+88cmtV7zefGnRlWJSKW172haM34YS0mNoU1ms+r445neTutB6CfMohhFPJ+Gp1hcH
         ZG8G2Vv0SYyVop6o9uzBwbch1oty9yQ7/XSG6wXPcuUa+Axuqp6W8HzDuaccb0o90mY5
         Us4YB4psgyvCj2v0KsnxXjVKAd3VUNP/UGcc9Oc3W3eEl6dKJi/XV7lErAgmaHi3NwxT
         m9Dg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=OHV4QGJwXMt6cTDDR9gAJliF74InHPXXIremhlCNuPU=;
        b=JRZaiNMieYVO7xxOg2nbtjpCgabE/fU3z7MHmeJE9Ujn3k4gVVZ9LKjCUGJuK2BxkM
         13ae1y8DInTk7WeACiPm0OJmnLjy/0/R0R5a3Grz4ZO3aOS9q1pXn11zDaPQR8QVdjbN
         8pWeX+9PA5VFdqjXT2To3M0FfHJVhegChLg1lqetypJoHsg5iTi+OjxAQqS+lNOR52nR
         xbyqjJJ8okoTPGfOnSRtubMgDKvFoqFPkMtL25+6df94QS3IMVrjQpnhLxD16dk2oTWg
         q0pGZOTAP4i5oXcF4yg1QpZnek913hIyC4FsWlOcmR07DCb7euW8v4B7g7hZMRx3Ancu
         uK9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=m8rpA8Tx;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id b7si2429012ybi.358.2019.02.14.16.54.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 16:54:27 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=m8rpA8Tx;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c660d9e0000>; Thu, 14 Feb 2019 16:53:50 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 14 Feb 2019 16:54:26 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 14 Feb 2019 16:54:26 -0800
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Fri, 15 Feb
 2019 00:54:25 +0000
Subject: Re: [PATCH 0/2] mm: put_user_page() call site conversion first
To: Ira Weiny <ira.weiny@intel.com>, <john.hubbard@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>, <linux-mm@kvack.org>, Al Viro
	<viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>, Christoph
 Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, Dan Williams
	<dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dennis
 Dalessandro <dennis.dalessandro@intel.com>, Doug Ledford
	<dledford@redhat.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox
	<willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Mike Rapoport
	<rppt@linux.ibm.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Ralph
 Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>, LKML
	<linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>
References: <20190208075649.3025-1-jhubbard@nvidia.com>
 <20190215002312.GC7512@iweiny-DESK2.sc.intel.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <4a326c1d-0ebb-5463-f7ed-8461bfa489df@nvidia.com>
Date: Thu, 14 Feb 2019 16:54:25 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190215002312.GC7512@iweiny-DESK2.sc.intel.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550192030; bh=OHV4QGJwXMt6cTDDR9gAJliF74InHPXXIremhlCNuPU=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=m8rpA8TxgQeOBZs6mHboNH4I3SHtCGoBV0ITcxs6fERzRDWqgDqPJjZff0Dg/YUj7
	 T2/6Qkxi6BRGl5QQRUqDDDHQoVj9g3wg2eb+6pHyCC/4vg+2UhunQ1OAXjw6kF40GZ
	 qlIXVrMYsxZz7j4PLMKoaUzyK2q8AYAp8VEzjRIgpS5ScP/34yIG6d7UVivcEb46hO
	 EWsK9dpg7heuwwZbsFmhy3UJGOE3V7FUsZe/Ui+knZpWNw/w5f2sakQedbtizKGYpd
	 vPbrGtVl1HQJcIZBOYQj/lSHOJMGSa49MyOC1TOnvrGofejPRb2Dp2otF+Vuoej7zm
	 GARy95cWHm/kg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/14/19 4:23 PM, Ira Weiny wrote:
> On Thu, Feb 07, 2019 at 11:56:47PM -0800, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
[...]
>>   mm: introduce put_user_page*(), placeholder versions
>>   infiniband/mm: convert put_page() to put_user_page*()
> 
> A bit late but, FWIW:
> 
> Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> 
> John these are the pages sitting in your gup_dma/first_steps branch here,
> correct?
> 
> https://github.com/johnhubbard/linux.git
> 

That's an old branch. In fact, just deleted it now, in order to avoid further
confusion.

This is the current branch: 

    gup_dma_core 

in that same git repo. It has the current set of call site conversions. 
Please note that there are a lot of conversions that are either incomplete
or likely just plain wrong, at this point, but it is sufficient to at least 
boot up and run things such as fio(1).



thanks,
-- 
John Hubbard
NVIDIA

