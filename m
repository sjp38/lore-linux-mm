Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A423AC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:39:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A0A62081B
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:39:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="qtvcv1dQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A0A62081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB3738E016C; Mon, 11 Feb 2019 16:39:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E3B8D8E0165; Mon, 11 Feb 2019 16:39:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D2AD28E016C; Mon, 11 Feb 2019 16:39:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id AFCDA8E0165
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 16:39:15 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id 4so292471ybx.9
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:39:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=R+UlXOuMWfVxi1VL88CZYA09pYGWsh6bByyqUXE80pw=;
        b=XM210FjyXJJ4CDGCg14LzkQv6i0GFwNko/AeFJgqKyxWL7r/3R3KhvpTqttO3l6QcR
         XTxqQa+y/ClrZvYQbLsZ/Hju/wrS5r/igqYjIdXYTBmbry79DmvHZ2W2BMsx27swmVC7
         ZnE/KYWpRbcQg214iD+T5UCJTB17qPSBJSdKYcRiPL9vmZIwVNApcbiSvtSjGrRzhcxi
         Aes9m6AK4pSpVlval2z3087nIhZALcU7i4fy+cb77u0t+ALX77muc52KzZMx4BC8hZi/
         T9XP3SrQysBgAmSbtAGysHMgKSv6jtX9zM9s3udjKwWa6PHQoTdjZaIx3B5Blq2g5wuE
         6IxQ==
X-Gm-Message-State: AHQUAuaCO+7n5o5BHOsuSDWG1rcaXlPNXbTrq/7eql6XwG2PohQYecns
	x1YdO/1PjUKf0iNONmLHGGp1cJpV8bTN3DooORnxRQfosFu0G527hoPRbWQhwwe9OqvBdZDIiCt
	QdMhtSdug+lKDhcsjOtt6FbYbxURJyAfRVKFOiYh97W0zpi/cLbc0LTEpIsVANb3R8Q==
X-Received: by 2002:a25:90e:: with SMTP id 14mr259325ybj.474.1549921155446;
        Mon, 11 Feb 2019 13:39:15 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYiQLsLOCTBiEpd+DS1Lc9J/r6cYTXzPyz9SKGvwBPVzSpD64HCle27xTuYO7NosBZgqaLT
X-Received: by 2002:a25:90e:: with SMTP id 14mr259295ybj.474.1549921154694;
        Mon, 11 Feb 2019 13:39:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549921154; cv=none;
        d=google.com; s=arc-20160816;
        b=ZIjeAL0Q54tH0wVcji3q8ROjs8+Glc8L7jkMzfoTRbxBixxBJSaqCTv0HtEBlpR98R
         3TAcSBriyiYzCo7C2ItBhW1FP0QptE3KMzKTObMbVaDRzrdew/Pjobo0YYzqFVEbqpy/
         z6HpM1PpwuujgowIyYSTwC8PEBqkzwOn/EaLLUNaaQc74/EqLpR2lZexa87IDSz+mlr9
         k8NVYa+kbz1OVJRMOfsb/1bqTTQnYSuYK12b/E6sxkMjbHtnHt+zp1ihLGAXrVSHfrMB
         vGb5ucL9mZF3iPS+JxsHRjPdcCp49MfC+/BqNl0jQlu4HhangJw5JHN/p/7SqJIv8p86
         oabg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=R+UlXOuMWfVxi1VL88CZYA09pYGWsh6bByyqUXE80pw=;
        b=poNbc+jhYguqBtNfkvt81m1gDRZhaUe/P0APDw44CezYLb6vYsFkYmuIwdaawlxGK1
         r1srOcVkD0Ipl8oPuPZm/Ttk9OWN/f2S+3MNW14TyepgolRLBcPqOqbCleCRa/qJ90mq
         NLswdtlBemUe+0E6fAScMPA24efjrzD0/lJU4BSiefurDGak3+73CRBzpOGni0wL4akk
         a7gGqRkBHYCgfOBy3wHqxhRZREwopLHeDH5KeMmVX7Gmy7MzT0SqJ1ab/5dwHnUhdfML
         unfycCQ63d5lytFJm5S7feMC8f3X9sKaYlhLnOY+T6jyMe7FRfNQEksjr5gYlLEKaX/K
         HvLA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=qtvcv1dQ;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id y11si6626298ybm.40.2019.02.11.13.39.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 13:39:14 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=qtvcv1dQ;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c61eb820000>; Mon, 11 Feb 2019 13:39:14 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 11 Feb 2019 13:39:13 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 11 Feb 2019 13:39:13 -0800
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Mon, 11 Feb
 2019 21:39:13 +0000
Subject: Re: [PATCH 2/3] mm/gup: Introduce get_user_pages_fast_longterm()
To: Ira Weiny <ira.weiny@intel.com>
CC: Jason Gunthorpe <jgg@ziepe.ca>, <linux-rdma@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>, Daniel Borkmann
	<daniel@iogearbox.net>, Davidlohr Bueso <dave@stgolabs.net>,
	<netdev@vger.kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>, Doug Ledford
	<dledford@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams
	<dan.j.williams@intel.com>
References: <20190211201643.7599-1-ira.weiny@intel.com>
 <20190211201643.7599-3-ira.weiny@intel.com> <20190211203916.GA2771@ziepe.ca>
 <bcc03ee1-4c42-48c3-bc67-942c0f04875e@nvidia.com>
 <20190211212652.GA7790@iweiny-DESK2.sc.intel.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <fc9c880b-24f8-7063-6094-00175bc27f7d@nvidia.com>
Date: Mon, 11 Feb 2019 13:39:12 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190211212652.GA7790@iweiny-DESK2.sc.intel.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1549921154; bh=R+UlXOuMWfVxi1VL88CZYA09pYGWsh6bByyqUXE80pw=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=qtvcv1dQDcYvz4XLbG382DqyBtFs0gGgLPWo8Xn6GcqHHK/Q47qW1gn5PIm2Xqek0
	 gsbpKLrTKOVlrsCPC7xQHKj0uU0zX+fN8JCfmpHUZsqa6mspIwjvkroaL2vUqeQThB
	 quUlcyu2fED+SuC5Ielkoooxk21AXSf/qrNDpehuUvaP4RIOSyWK0CK5jbn9d/4ZRX
	 If5r4u/Fu3FG2rAgipSY8cm5Tm047SxqP/wKz9RzJgyp81HeZJMI+VZtahMpyOU0fk
	 Nk7XjF3ubZa+WGlxRmO2x0qbr3vD1iicYykjC7ShI8CoBdzWB4/xHEmZe3hVGYi4re
	 CqxTmm2qLEtWQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/11/19 1:26 PM, Ira Weiny wrote:
> On Mon, Feb 11, 2019 at 01:13:56PM -0800, John Hubbard wrote:
>> On 2/11/19 12:39 PM, Jason Gunthorpe wrote:
>>> On Mon, Feb 11, 2019 at 12:16:42PM -0800, ira.weiny@intel.com wrote:
>>>> From: Ira Weiny <ira.weiny@intel.com>
>> [...]
>> It seems to me that the longterm vs. short-term is of questionable value.
> 
> This is exactly why I did not post this before.  I've been waiting our other
> discussions on how GUP pins are going to be handled to play out.  But with the
> netdev thread today[1] it seems like we need to make sure we have a "safe" fast
> variant for a while.  Introducing FOLL_LONGTERM seemed like the cleanest way to
> do that even if we will not need the distinction in the future...  :-(

Yes, I agree. Below...

> [...]
> This is also why I did not change the get_user_pages_longterm because we could
> be ripping this all out by the end of the year...  (I hope. :-)
> 
> So while this does "pollute" the GUP family of calls I'm hoping it is not
> forever.
> 
> Ira
> 
> [1] https://lkml.org/lkml/2019/2/11/1789
> 

Yes, and to be clear, I think your patchset here is fine. It is easy to find
the FOLL_LONGTERM callers if and when we want to change anything. I just think
also it's appopriate to go a bit further, and use FOLL_LONGTERM all by itself.

That's because in either design outcome, it's better that way:

-- If we keep the concept of "I'm a long-term gup call site", then FOLL_LONGTERM
is just right. The gup API already has _fast and non-fast variants, and once
you get past a couple, you end up with a multiplication of names that really
work better as flags. We're there.

-- If we drop the concept, then you've already done part of the work, by removing
the _longterm API variants.



thanks,
-- 
John Hubbard
NVIDIA

