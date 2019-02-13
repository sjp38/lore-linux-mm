Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75978C282CA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 02:58:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3295520835
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 02:58:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="ZxwYf3wv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3295520835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3E0F8E0002; Tue, 12 Feb 2019 21:58:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AEC758E0001; Tue, 12 Feb 2019 21:58:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B3F18E0002; Tue, 12 Feb 2019 21:58:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 78E148E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 21:58:13 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id 67so553940ybm.23
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 18:58:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=pYuUD8ixt0DUBPAmr4vJCg8DY/4XZggnruE+tkGT2iI=;
        b=iNE7yIZgFTewqNq7UFSzi0frB+INtzq4b5Y/L8uGp0kfNk0NN5SoWyYPvzjp1qMi6E
         cCGEeOvOZps11xJVzc4ov0/kAq6OI+zgJTtDS0rG0mV/QKQ6h2o/AuIlecoSaWk1O5xW
         JYyByJkHnwTW3F6Dr62KxL9eGiOk2dYA+MxFMQkEKmabP6grXkmSF/Xqii6xruRsMHVd
         wHgovVpzeq9hNO5ESSroRyJNx+u1Cv3/oZPzcGUlXHufp8m5/136mRdk1SBA+F/oUEpR
         gVcogU8CoKUDQnlFfaoyn3yGThu/uhcao0x3UvLIJ2+MjZGAVWd5f6QCb1aOXeEJUr1x
         weyA==
X-Gm-Message-State: AHQUAuZtVWWV2TkS0dRZ9uT9XGUSp3om5Cxn0DrlhNF4DfsCoBMIKeCM
	hgxg3eUKC+PELRxA3Sf+SulHBt4gLFmRKP2cWsO+qG2YlZ7KNfVoIRNB77tkk6uaueInXKpAwes
	L6bJZ7geQvhXNOYVufjxW34QCKiF9tCigzdP0Fu/7alhhQCIiqm9sN4OSO02Z6g66DQ==
X-Received: by 2002:a81:7d5:: with SMTP id 204mr2909680ywh.143.1550026693117;
        Tue, 12 Feb 2019 18:58:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZKM6mtxxfZukjLM+eITArrQf+Rtnd1WePTrdOGozIQbi9+bE4T/gjCMDLXw0X4sKM5EycZ
X-Received: by 2002:a81:7d5:: with SMTP id 204mr2909646ywh.143.1550026692125;
        Tue, 12 Feb 2019 18:58:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550026692; cv=none;
        d=google.com; s=arc-20160816;
        b=eJvri5TAR1hkkRzP1iFF7pVSdggtliCRnDUOkVmuM/WE8RhAeEya9JhxBFFREEs27x
         YFgigFRG86AeSTVDGFGhtcvJAgXBnUWNKvfmL27PYz5bB3pIU/CijgwupR9tlQqdr5Pi
         Q3Mp5do8uasdbfs59IzAZNx1koqK0jYHwV8/ri5xMBYKgjVhe70W5pA52iSk0xAYWav2
         RN3N4JiOngc9XoDQ06rWe4Lzrsglx9uCKg+j/HfKdVMfprhQYxh9ltpy4WXh7/rvMqj6
         fY7pmfKOlzlZ8JdCOGfUV/6OSk+dTLfPMc4AqFlC9OO5M9oSRyoRT7JNt4kl7ReSF0Qn
         0FVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=pYuUD8ixt0DUBPAmr4vJCg8DY/4XZggnruE+tkGT2iI=;
        b=BfDzOvI3symdq2K3cF1RhwJVn/RkYLKYD+Scd4YoKKPlJ1dPsn+T4BsKMnc5qEn3t7
         yp0qqbbJ3fDo4inw0pB3r+P9KqC8EKaDqp54FfKVZ1TP7gjb3K1xvDlctK6ZEX9EeXnm
         BZEwWb4iEgtN/s9urL7rgZdJXL6jEdAcN0Gg8+Yxc4CDmkvNT5XYDpqAcwGN1HT/v6DA
         ytZw+/gqO0MDsm23rVRan9cIOhV/o/+g0i+p2EMy5Wro5FglzmICJikcU5dC9Ph1ZwzI
         KpylXP5mwvBydkbu25HT0Flfz6gZ/jzqX2m5erCd2yDZjzimzg3YUHR7+PnXfzHFbwmG
         wb3w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=ZxwYf3wv;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id n185si9022868ywe.430.2019.02.12.18.58.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 18:58:12 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=ZxwYf3wv;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c6387c60000>; Tue, 12 Feb 2019 18:58:14 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Tue, 12 Feb 2019 18:58:11 -0800
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Tue, 12 Feb 2019 18:58:11 -0800
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Wed, 13 Feb
 2019 02:58:10 +0000
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
To: Christopher Lameter <cl@linux.com>
CC: Jason Gunthorpe <jgg@ziepe.ca>, Ira Weiny <ira.weiny@intel.com>, Dan
 Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Dave Chinner
	<david@fromorbit.com>, Doug Ledford <dledford@redhat.com>, Matthew Wilcox
	<willy@infradead.org>, <lsf-pc@lists.linux-foundation.org>, linux-rdma
	<linux-rdma@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel
 Mailing List <linux-kernel@vger.kernel.org>, Jerome Glisse
	<jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>
References: <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
 <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
 <20190208044302.GA20493@dastard> <20190208111028.GD6353@quack2.suse.cz>
 <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com>
 <20190211102402.GF19029@quack2.suse.cz>
 <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
 <20190211180654.GB24692@ziepe.ca>
 <20190211181921.GA5526@iweiny-DESK2.sc.intel.com>
 <fb507b56-7f8f-cf2c-285c-bae3b2d72c4f@nvidia.com>
 <20190211221247.GI24692@ziepe.ca>
 <018c1a05-5fd8-886a-573b-42649949bba8@nvidia.com>
 <01000168e29418ba-81301f56-9370-4555-b70c-3ad51be84543-000000@email.amazonses.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <b8794103-5ae1-ff8d-22be-d585d36e6310@nvidia.com>
Date: Tue, 12 Feb 2019 18:58:10 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <01000168e29418ba-81301f56-9370-4555-b70c-3ad51be84543-000000@email.amazonses.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550026694; bh=pYuUD8ixt0DUBPAmr4vJCg8DY/4XZggnruE+tkGT2iI=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=ZxwYf3wvJ76h2srywAkRBqh0CcEH377shxMYRyeclrKz53nOM8sGge/1XvuYsP9ar
	 TmhlGr4nkQbxlKf+4H6dRCTef9wcC0cdAvx0n9d4KZZ6x0utDA4UkbGE/+pYafrpvv
	 7VlWtcpwsZCx/7SNoI5JM5QydMnIWsESr6vNbAQLIrbmrdJhCcsD5Vq+Pi0tnHtoCf
	 C8DwXWTDxFBDspe1bsrv4GSrCIGlrtw70AhRbRUx0jlk1wqIDcwavouzCD+43Ded6A
	 KE35oMbqiXM0mWUKd1ikOhSMlmUS2v6yk7v1Dw2fBg+r1nI6bk33DSg7f9eGF2bRWn
	 bOYN0flqnZMPA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/12/19 8:39 AM, Christopher Lameter wrote:
> On Mon, 11 Feb 2019, John Hubbard wrote:
> 
>> But anyway, Jan's proposal a bit earlier today [1] is finally sinking into
>> my head--if we actually go that way, and prevent the caller from setting up
>> a problematic gup pin in the first place, then that may make this point sort
>> of moot.
> 
> Ok well can be document how we think it would work somewhere? Long term
> mapping a page cache page could a problem and we need to explain that
> somewhere.
> 

Yes, once the dust settles, I think Documentation/vm/get_user_pages.rst is the
right place. I started to create that file, but someone observed that my initial
content was entirely backward-looking (described the original problem, instead 
of describing how the new system would work). So I'll use this opportunity for 
a do-over. :)

thanks,
-- 
John Hubbard
NVIDIA

