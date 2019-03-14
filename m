Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B828FC10F06
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 16:00:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 726D921855
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 16:00:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 726D921855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 293FB8E0004; Thu, 14 Mar 2019 12:00:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 21BCA8E0001; Thu, 14 Mar 2019 12:00:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0956D8E0004; Thu, 14 Mar 2019 12:00:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id D6EDB8E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 12:00:20 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id f15so5752020qtk.16
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 09:00:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=RV7ui4srl151Wq3HppMuSrvuofM04oVlcrm+/5+4Krs=;
        b=mly5uvfNawQUebuNqIm5pfYgXh4lDo0vGXiBEOD96oPFZQ87oeh0WPcKp1UXuYNt1u
         bO/Ffwf593j2l//SbhvkvOduxhp6cxcd6JdL1wqYdaRHwPadvJDdyhkB+00q4k9Fzk7i
         F2Xka8hcbyEZcXbabYeBLvIpRWXlm9PB6lsGo0gj6SH+dptO8AyZt1nULjawk8PoEZqA
         uV7lff1ks20RJCi+hgLeL9UayWatwWf0x1kl9jmvEq2s2/Q1gLl9PxFxRiqjgeDJnFlU
         T3rZW5fnF7dTjKWTO4zZp3nsxkwkdRjkLOz1vlqlpFUWmqAhtwypNTjt+mKcSJPSwWIN
         SBzg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUSDh94nYgkyxG9odKiO03+Grhm4jbje73d/NC2aiHfVYcFhyn6
	iIagmgld/UN46vzsIWo34FbINGCUxd4deNDO4gQ5kXXXtfjWcMItdzY8LPrEZ7OUzGjA9E2BPI3
	3xhkEa44yemGlbRpTDC5Y2sLRbajiGpFKoWznSSPE6FL/ITr6RHSDxCRFsG+H8mm8ww==
X-Received: by 2002:ac8:18ad:: with SMTP id s42mr1596664qtj.42.1552579220702;
        Thu, 14 Mar 2019 09:00:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8RdngnYrymF0o2UQXoXuEdO3/vXyffkOs4ajm9pWBnFNRvb85sHZ38PeF6/F7NH63xGhZ
X-Received: by 2002:ac8:18ad:: with SMTP id s42mr1596593qtj.42.1552579219834;
        Thu, 14 Mar 2019 09:00:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552579219; cv=none;
        d=google.com; s=arc-20160816;
        b=txeIIZODzBa1wt0i7iE+yGRKBFp6ycs3pc0Gfuyx24EmFw6P3MlGfEPV6/LntavBwT
         xzh3AUs8G76ioPgLv5zvM4S5E7Yloe/bjyV76HgKPp6Qzr537YrFNsS7BKCSkgL45Wj0
         dJAzqi77TELDxuU3qHlUQYfQbqYKEo+F85TqDeBGeAFTiWxYidwddhECg9kgLF1kf5jg
         hyvdTqPh9tiOfWEs/Ag/5+hTBQ2An92pLF7dHXM3REEYO31PEK3R+AcK3GrdRyt5rwfA
         FKE+io1z7bDGCupgKyOoUyrhVTvDdxzLm6nUbqt35e7xydp5uPMcHvDjOop/yo4/BbfM
         l/Dg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=RV7ui4srl151Wq3HppMuSrvuofM04oVlcrm+/5+4Krs=;
        b=v8foJjTIGsOpA2BqDaDYDFOpMvdJCgKzIr2ts4Dl3VGJiimtjSUjPOeoIduj3sKZz6
         tR2YxJlfhfW7l1zFQlEazT0SsSYIClTUiU4OLB/8SPw2cslCwweRN42ntIWADFq9A5g8
         ZAIOHMAmV/4VdJrFiqI8cpvq4kf9c5RZPdHYwsub/KhRXd3mken55qJalzftF/P8sH69
         YkbgEr8hrIfg8tsxc2bL+AhDwx1JRn0+j18N34WC4aIYFS3MiP+5LCYlXZXd51f1/yNN
         epf7JAb1+inM1nIONC0ABkuK0LSae8l1m+OcQ+6u78uCSi10J0RihZwnMQMYLDBCLqz4
         pYng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s43si2863375qvc.88.2019.03.14.09.00.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 09:00:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id EF75781138;
	Thu, 14 Mar 2019 16:00:18 +0000 (UTC)
Received: from [10.36.117.188] (ovpn-117-188.ams2.redhat.com [10.36.117.188])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8B32460F87;
	Thu, 14 Mar 2019 16:00:16 +0000 (UTC)
Subject: Re: [Xen-devel] [PATCH v1] xen/balloon: Fix mapping PG_offline pages
 to user space
To: Jan Beulich <JBeulich@suse.com>
Cc: Julien Grall <julien.grall@arm.com>,
 Andrew Cooper <andrew.cooper3@citrix.com>,
 Matthew Wilcox <willy@infradead.org>,
 Stefano Stabellini <sstabellini@kernel.org>, linux-mm@kvack.org,
 akpm@linux-foundation.org, xen-devel <xen-devel@lists.xenproject.org>,
 Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross
 <jgross@suse.com>, linux-kernel@vger.kernel.org,
 Nadav Amit <namit@vmware.com>
References: <20190314154025.21128-1-david@redhat.com>
 <5C8A77FD020000780021EC87@prv1-mh.provo.novell.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <81175478-d6cf-56ce-587c-87473e79fd50@redhat.com>
Date: Thu, 14 Mar 2019 17:00:15 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <5C8A77FD020000780021EC87@prv1-mh.provo.novell.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Thu, 14 Mar 2019 16:00:19 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 14.03.19 16:49, Jan Beulich wrote:
>>>> On 14.03.19 at 16:40, <david@redhat.com> wrote:
>> --- a/drivers/xen/balloon.c
>> +++ b/drivers/xen/balloon.c
>> @@ -604,6 +604,7 @@ int alloc_xenballooned_pages(int nr_pages, struct page **pages)
>>  	while (pgno < nr_pages) {
>>  		page = balloon_retrieve(true);
>>  		if (page) {
>> +			__ClearPageOffline(page);
>>  			pages[pgno++] = page;
> 
> While this one's fine, ...
> 
>> @@ -646,6 +647,7 @@ void free_xenballooned_pages(int nr_pages, struct page **pages)
>>  
>>  	for (i = 0; i < nr_pages; i++) {
>>  		if (pages[i])
>> +			__SetPageOffline(pages[i]);
>>  			balloon_append(pages[i]);
>>  	}
> 
> ... I think you want to add a pair of braces here.
> 
> Jan
> 
> 

Indeed, dropped by accident. Will resend in a minute. Thanks!

-- 

Thanks,

David / dhildenb

