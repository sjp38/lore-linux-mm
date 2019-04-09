Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2A13C282DA
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 08:07:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 785DA20663
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 08:07:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 785DA20663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 137616B0006; Tue,  9 Apr 2019 04:07:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E6156B0007; Tue,  9 Apr 2019 04:07:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF1136B0008; Tue,  9 Apr 2019 04:07:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9EEE36B0006
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 04:07:46 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id w27so8341165edb.13
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 01:07:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=lrz9BacXx7IE9OmicqnmhhfhbZYC7hsHUWLL+aOflZs=;
        b=tm94nodaBmTMd+iopDzsfo/K5oV1OYCUXwYSmmgjMWZzca7KLy70QlFPgchdH3SCqK
         ap4OKRct2t3nzwu5p8NgcDV+GrMGfbJ4exzftWm+z9vqYIWKSJ0ASCwdYG83bdgzUtcu
         FWWmlFjzcdFKrHnLebn+AsNtI0J9XEzr7v3DjLvm4YE2TK/bMQB9XbIfBQsYrUPaIcSX
         4Zcb/4LmgoyiBDORC1MEx3nyvqQNwhTAkC6v+Fy4TnrwtD6SMGLn/QbNGB3LnA2hiNml
         OErH/AnUP84AuSzqLwZ/fXKAbszm4KRm437VSUu6Uy1mMldQp9uILWcIdXBDqLgV08Yy
         +jEg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAVZ0cV92B33cKVLdFNuq0lQxrW7MziUf+5Jv3Zcmz+gEfFHU7IX
	UN1pB89+S4+Rpn9PnJxMkad1bZhHMJWWX9sh8kHLqtxgQzFPxMH2DnGPQeLsXhn9gRu1xNxq2wL
	WxwUUn6m8bez1AxwLzqZv98DMNpT+jcSjbj6Enyu1Gm+bpKc4a5SY4eKf8RtpxPpFDw==
X-Received: by 2002:a17:906:e285:: with SMTP id gg5mr18856519ejb.229.1554797266200;
        Tue, 09 Apr 2019 01:07:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy9JxdtE9Xuy63qe++GPSHJcTYnXucM4Bxa60QWp+rLQwX+1g2IduJv33mGvtLLPKa2PDha
X-Received: by 2002:a17:906:e285:: with SMTP id gg5mr18856477ejb.229.1554797265324;
        Tue, 09 Apr 2019 01:07:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554797265; cv=none;
        d=google.com; s=arc-20160816;
        b=YUQ6+u8PMGcNBi8c8MpdgpIgV1Op4+zS5tECwa4XlcnyVh135ANjLXmsLFl/Ck/dI8
         LsyUH55I0z0YwJ1gmsylt/5Du11Ybv+ld3bJ0NWRD9pDjyvh6L9p7+gVFpBt6sTmBNwe
         mXfIPLSyekoqJcrImpAcdsYUMZ+ULxM4RbexQU//VRkCStGNet8TX8LmTGGZOLwr2qLo
         OcBEWxJb97YoN2aZyAfZQJ3MWgDulDEkoNT0XCoEO5FT9D7O82hm51yJMJeeE5iim2w3
         VQbgFdobrCpriZ6RxAw8zlzNE9iWAqMTbhHeAhks+CI9CqxVMZLI13d/l6tLzS8kL2hT
         MEpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=lrz9BacXx7IE9OmicqnmhhfhbZYC7hsHUWLL+aOflZs=;
        b=n/p8s3Tzt8b7EnxiNhAK7mBnyqR65wkPIQdFC1/XSCFGH+G3wqzE+ZoeRCpoRH7AGi
         He4ufVn2Qbg8CM6jhU+7z+jXxaLSK/GQ/x9F5l0axxtmeSadbqv+Va5ypcXn+sUi37Ve
         pPqiSS9R/2zmauPXIVj9FVu/cMjvjLtCiVkpis9eZPn7yRHJlFGrGydA4H3Mt9rlZ/6D
         FnwigCHxg8L9y1+BHsenmk6UDc86qk7UqrVENrxixAQzQeZ5SaT3/MsULm0mXHhH63RQ
         bxYiZEMug3qjzpVLUvjShSeve1IXnGePbSvZmtIMtCXZkMb/O/Q+Lu4Eoyy58SZkwG9Y
         iyBg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m4si2586752edr.313.2019.04.09.01.07.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 01:07:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DAE55AC97;
	Tue,  9 Apr 2019 08:07:43 +0000 (UTC)
Subject: Re: [RFC 0/2] guarantee natural alignment for kmalloc()
To: Christoph Hellwig <hch@lst.de>
Cc: Christopher Lameter <cl@linux.com>, linux-mm@kvack.org,
 Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ming Lei <ming.lei@redhat.com>,
 Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>,
 "Darrick J . Wong" <darrick.wong@oracle.com>,
 Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org,
 linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-block@vger.kernel.org, lsf-pc@lists.linux-foundation.org
References: <20190319211108.15495-1-vbabka@suse.cz>
 <01000169988d4e34-b4178f68-c390-472b-b62f-a57a4f459a76-000000@email.amazonses.com>
 <5d7fee9c-1a80-6ac9-ac1d-b1ce05ed27a8@suse.cz>
 <010001699c5563f8-36c6909f-ed43-4839-82da-b5f9f21594b8-000000@email.amazonses.com>
 <4d2a55dc-b29f-1309-0a8e-83b057e186e6@suse.cz>
 <01000169a68852ed-d621a35c-af0c-4759-a8a3-e97e7dfc17a5-000000@email.amazonses.com>
 <2b129aec-f9a5-7ab8-ca4a-0a325621d111@suse.cz> <20190407080020.GA9949@lst.de>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <af1e0b95-f654-4fa9-d400-af01043907ab@suse.cz>
Date: Tue, 9 Apr 2019 10:07:42 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190407080020.GA9949@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/7/19 10:00 AM, Christoph Hellwig wrote:
> On Fri, Apr 05, 2019 at 07:11:17PM +0200, Vlastimil Babka wrote:
>> On 3/22/19 6:52 PM, Christopher Lameter wrote:
>> > On Thu, 21 Mar 2019, Vlastimil Babka wrote:
>> > 
>> >> That however doesn't work well for the xfs/IO case where block sizes are
>> >> not known in advance:
>> >>
>> >> https://lore.kernel.org/linux-fsdevel/20190225040904.5557-1-ming.lei@redhat.com/T/#ec3a292c358d05a6b29cc4a9ce3ae6b2faf31a23f
>> > 
>> > I thought we agreed to use custom slab caches for that?
>> 
>> Hm maybe I missed something but my impression was that xfs/IO folks would have
>> to create lots of them for various sizes not known in advance, and that it
>> wasn't practical and would welcome if kmalloc just guaranteed the alignment.
>> But so far they haven't chimed in here in this thread, so I guess I'm wrong.
> 
> Yes, in XFS we might have quite a few.  Never mind all the other
> block level consumers that might have similar reasonable expectations
> but haven't triggered the problematic drivers yet.

What about a LSF session/BoF to sort this out, then? Would need to have people
from all three MM+FS+IO groups, I suppose.

