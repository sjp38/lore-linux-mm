Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D6BAC00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 21:25:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16FB52084D
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 21:25:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="aiRzGUhQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16FB52084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 893A48E00B7; Thu, 21 Feb 2019 16:25:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 841DD8E00B5; Thu, 21 Feb 2019 16:25:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 732128E00B7; Thu, 21 Feb 2019 16:25:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 476C08E00B5
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 16:25:05 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id c74so59853ywc.9
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 13:25:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:dkim-signature;
        bh=VW57buSV9PMYWQz48J9UmJOo0JrnTIg+0Kl1EdES2N4=;
        b=jB5aeYl3JKYTbCimltsqK4dqQ6fRUl47yAzuyTjKOBZ+F6MaadeY4Tt/ldvvnaPj71
         ahsLYsS8PRtx1Hi51osF+jRvIbpBSQtFHD35YQIt39qKOe39sb2FxDEOS2JeF3fmLWZp
         tTJipy0zfX5uNrjDdFACR2iDjBJvNGJslN35Pe54G3yUBf1IV02NBofnSOR415YGlbto
         HgVXcK7cgpSXQDTfg18FCX5216OUVBPrYohCbNPzT4YO2PYcRwc+DFQCPKBTUEKl1Pzi
         HJ6fMxw23gbPDMdma++4z7AAZKctXTE3l/JzbJB9fBByEkctry/mjKeqB3SPdISpgOLp
         0X4A==
X-Gm-Message-State: AHQUAuYGtlB8+UL5zkYTitDO72noWISDmRHXhKp005UhpuT3aTe+87RQ
	M4mev7adtprclYQMwbtI2O18k0GRID9nDx4Pk6+1AKuGNwjqECeOCrjCjwvjSYVAQJCpXdRPXwf
	+srZEkRabQmnWTfS5k1i+42pG/Lglnsf1qAJUwyptjmEiaRxOA1Jb3JinbmOR+7I77w==
X-Received: by 2002:a81:4c8:: with SMTP id 191mr536262ywe.322.1550784304955;
        Thu, 21 Feb 2019 13:25:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iac0SPfRQRj1CiPHXq/wQmWR3TyPLi8ooWg6KV8DVmZYpqdK5RQ2Xk+7sYnougIA46PjpHa
X-Received: by 2002:a81:4c8:: with SMTP id 191mr536230ywe.322.1550784304422;
        Thu, 21 Feb 2019 13:25:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550784304; cv=none;
        d=google.com; s=arc-20160816;
        b=ZxRL1PhtnVecgnZhhT+SZVXGAd8L1rPe18mIFajza8NI1jP9nzn3TAme0jL8cKBjhd
         E3uJasNPkDiKyWi8xuA/UKGVd0jJVIL5nlSPWZ8N/0Fjl3WZoPKcbXWN7TUIJGOrpcNe
         FEEf+cUwJBWEZ4UntOQYpNZ8tx0qcJ2jC4BAe9K1BufcU+Dr82w4cK4XnhX3ROKh7cow
         ZbyFHUqcXffEYRVDP19WWId1ADb0r6fZMqkb+TNdTle5fWST6xvEMDcTAs2EdRBhSlo6
         PTLD6xBLlyakn14JKSTlHse4MKSGA8neNIhyrnHUhwPuAKGasx9CmZW9sKS+mCaVY2Lt
         twkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from;
        bh=VW57buSV9PMYWQz48J9UmJOo0JrnTIg+0Kl1EdES2N4=;
        b=J13ZSj/rTTZ2Ao+8qYkdk9bkkOhm5KCT4B8OEBEtGl1nL0oNGm4HWT7O9SK6Lqd7oB
         XnxGDv5Ct+fYoNGzieJUpTGKELwRKHCtrGyaGi19yYoJEuF1i59lpsaQFAoYRTyZAWwX
         deT3wZ+uZlJJTcGZRawiS+DgKtOoqHtKUHv3+2j9jfAf0kabynJCs2blbo1GwQhObooW
         ybqCNLJrezDdGzeXbQkWCgITmztthXGr/EtC4VQY/ca0At7W5Ldlxei1MzDyPuHCE+kG
         zP9+r8I78gT0itqQvnJ09GKxDpC/yeK0WoQnEjpAKGo83bpF5ClrZQeEXd8fIn+GD+JV
         5/7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=aiRzGUhQ;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id z6si12759099ywe.375.2019.02.21.13.25.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 13:25:04 -0800 (PST)
Received-SPF: pass (google.com: domain of ziy@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=aiRzGUhQ;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c6f17370001>; Thu, 21 Feb 2019 13:25:11 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 21 Feb 2019 13:25:03 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 21 Feb 2019 13:25:03 -0800
Received: from [10.2.161.21] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Thu, 21 Feb
 2019 21:25:02 +0000
From: Zi Yan <ziy@nvidia.com>
To: Jerome Glisse <jglisse@redhat.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, Dave Hansen
	<dave.hansen@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton
	<akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman
	<mgorman@techsingularity.net>, John Hubbard <jhubbard@nvidia.com>, Mark
 Hairgrove <mhairgrove@nvidia.com>, Nitin Gupta <nigupta@nvidia.com>, David
 Nellans <dnellans@nvidia.com>
Subject: Re: [RFC PATCH 01/31] mm: migrate: Add exchange_pages to exchange two
 lists of pages.
Date: Thu, 21 Feb 2019 13:25:02 -0800
X-Mailer: MailMate (1.12.4r5609)
Message-ID: <3AE8BFB7-139B-4312-A0A7-50759BA63362@nvidia.com>
In-Reply-To: <20190221211038.GC5201@redhat.com>
References: <20190215220856.29749-1-zi.yan@sent.com>
 <20190215220856.29749-2-zi.yan@sent.com> <20190221211038.GC5201@redhat.com>
MIME-Version: 1.0
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550784311; bh=VW57buSV9PMYWQz48J9UmJOo0JrnTIg+0Kl1EdES2N4=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type;
	b=aiRzGUhQbpIFpXcfTrDEvOdfujPjXdkqyIBrV2OOqD30hq7BtgcxDRplyHtdWxmEf
	 GdH2+JEL7ChdJIcp93Lw3Pqh3N0pX+3ls7McbewYwG5qKA3rbOw5AWaTL4z2jRy40D
	 0EA5MBqL28BWjuStftJrRJ2vlg5Z3WAV3rPUd0ZAca2NZQL1XqzUOEpjJt0gzzKpIX
	 18BIX4Tstk2+k6fkGpPoIH1Ih1PjjsuNKL5tTm7mUBQGKx7NXi+MqVxetD0Xuk2Y/2
	 AMG8UrHvuOHFEoHSr6xzMBxL+yMxHj5LkhdrLk4WM432oYLe5M3kt7k0PB/L+M95W4
	 DLmq9PENyuWOQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 21 Feb 2019, at 13:10, Jerome Glisse wrote:

> On Fri, Feb 15, 2019 at 02:08:26PM -0800, Zi Yan wrote:
>> From: Zi Yan <ziy@nvidia.com>
>>
>> In stead of using two migrate_pages(), a single exchange_pages() would
>> be sufficient and without allocating new pages.
>
> So i believe it would be better to arrange the code differently instead
> of having one function that special case combination, define function for
> each one ie:
>     exchange_anon_to_share()
>     exchange_anon_to_anon()
>     exchange_share_to_share()
>
> Then you could define function to test if a page is in correct states:
>     can_exchange_anon_page() // return true if page can be exchange
>     can_exchange_share_page()
>
> In fact both of this function can be factor out as common helpers with the
> existing migrate code within migrate.c This way we would have one place
> only where we need to handle all the special casing, test and exceptions.
>
> Other than that i could not spot anything obviously wrong but i did not
> spent enough time to check everything. Re-architecturing the code like
> i propose above would make this a lot easier to review i believe.
>

Thank you for reviewing the patch. Your suggestions are very helpful.
I will restructure the code to help people review it.


>> +	from_page_count = page_count(from_page);
>> +	from_map_count = page_mapcount(from_page);
>> +	to_page_count = page_count(to_page);
>> +	to_map_count = page_mapcount(to_page);
>> +	from_flags = from_page->flags;
>> +	to_flags = to_page->flags;
>> +	from_mapping = from_page->mapping;
>> +	to_mapping = to_page->mapping;
>> +	from_index = from_page->index;
>> +	to_index = to_page->index;
>
> Those are not use anywhere ...

Will remove them. Thanks.

--
Best Regards,
Yan Zi

