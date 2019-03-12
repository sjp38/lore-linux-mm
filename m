Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE5D9C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 07:15:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70B50214AE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 07:15:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70B50214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB1718E0003; Tue, 12 Mar 2019 03:15:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C5EA58E0002; Tue, 12 Mar 2019 03:15:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4E348E0003; Tue, 12 Mar 2019 03:15:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 943AD8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 03:15:33 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id x12so1464549qtk.2
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 00:15:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=qV3ts06kKPHXpxmxqLa6E357semK7amInOVXS3sY5QY=;
        b=KenZagCPAxHcc1joTh2AGGTLPdtFkEkPJrAiQwCXAtQWh9Ch/9IfKrNi0PrWLWfYDE
         ZEJ3y7H0IaGdODn1qn8BQKAX6TVLv2OQ33XS0v7XaTmCrnYXtBjbvksTky6TBzdzcsUI
         KUz/Oik7GvDR35NsFbzyqSb8KoPvnT6vsVh9VMy7iXfBgQQqQXEVnkqdmRp6mBpMacyH
         a58QqhriOWt/AUKB5cOxbTqy2xOZN2TTQhe6N6upIGoZOeiHja+yk3IFpW/CMC97Nwe2
         BkVknjf+zsojURGAn9Ypja6iSE13mrhtAog5x7ekm+64poYGVqST9+7zt9NVo0YeSt/f
         4jPQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWzrGGp+7qySOH44ftC0QyslIVYM8Kz7FLGdfB+hGyGsU6WHmZq
	KttlKYH1NXHjGkOY04R6YXhChEzo0usjz2n3ZVGMpSfa9+CGDJ0tyHxu4RZycf4lk/ADmL3YIzK
	HZR9On86CT6nuc2PcEx7WgqtfEDoVceCr2qIZFBERdPwmPssdMt2uYK9nrf5B7VEq4g==
X-Received: by 2002:ae9:c20f:: with SMTP id j15mr25205044qkg.132.1552374933375;
        Tue, 12 Mar 2019 00:15:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzA1tsa0SSoYM5pnK16qA8v76v0khEtl5ey6+3UN15E3MkKSeWUKhY1/GLnw292a0zcIi0N
X-Received: by 2002:ae9:c20f:: with SMTP id j15mr25205017qkg.132.1552374932691;
        Tue, 12 Mar 2019 00:15:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552374932; cv=none;
        d=google.com; s=arc-20160816;
        b=IP8nuk3NivSTkGYoILLNWZ994RMOd1SSljnmDwp2pEh/YPnvrLS6U4m4ucHAUomGHs
         ReYlX876a8gD0XS6OiDSYt78GeDIseEh9x8K1761vcJtGkrujiwE8rHIVd0ZIoa5fFy8
         UZh1JpaGSjPpjSHeNnCyyQhFEbedzc7yhyEFjhX8+tU60WfLae7ziLAwJiFbVVjxOk1J
         PHh3gXYf0bVB9Auxp5lPbPAUKAwtabDX1hUPgNMoZZxVSj65c59Z455EGU3bIAXl+Cny
         FzFSH6JtlxasoYmMMG3iFaKu0lkr+AOTxHSdUNyO5gm3osRS8+kjUn/k1RcNyd8SRIAJ
         vJiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=qV3ts06kKPHXpxmxqLa6E357semK7amInOVXS3sY5QY=;
        b=lnyuxLeSV91StdBrUOaGiv2oerutkVmo0uICV3TLVvp/fvmffuWhIupYlmHV7h8iIG
         Hb6u4O6a+t32a9N4ng1WjfbysTcwKnRqIgVINjPJ1EZ06ZmGhyDNOwmFA40v4UvtT4OQ
         vQX8hnnFsZcABsjh8+plHmMcaU3sEfGMgew5QqVLHb23BSw9nK6/2VbCX7m7vkGoeQi7
         JjrnPvhk11oCPX5Y8hfYqKOswz9FKY5yh5zJy7dZd/w4/X5Kzzss68AqEr+j9inv0jf/
         FBQxxDWsoyebH7tECrGBu75YkwsmX/n8rKDSLm4WtarrAHrAfAhGYAmRnEo/uFaKxTDn
         /fNA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y35si1285847qty.173.2019.03.12.00.15.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 00:15:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E75A2723D9;
	Tue, 12 Mar 2019 07:15:31 +0000 (UTC)
Received: from [10.72.12.17] (ovpn-12-17.pek2.redhat.com [10.72.12.17])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 0731660A9A;
	Tue, 12 Mar 2019 07:15:23 +0000 (UTC)
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
 Jerome Glisse <jglisse@redhat.com>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190307103503-mutt-send-email-mst@kernel.org>
 <20190307124700-mutt-send-email-mst@kernel.org>
 <20190307191622.GP23850@redhat.com>
 <e2fad6ed-9257-b53c-394b-bc913fc444c0@redhat.com>
 <20190308194845.GC26923@redhat.com>
 <8b68a2a0-907a-15f5-a07f-fc5b53d7ea19@redhat.com>
 <20190311084525-mutt-send-email-mst@kernel.org>
 <ff45ea43-1145-5ea6-767c-1a99d55a9c61@redhat.com>
 <20190311234956-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <3b00dc4a-b1b7-aa3f-c4ba-515138e4d6dd@redhat.com>
Date: Tue, 12 Mar 2019 15:15:22 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190311234956-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Tue, 12 Mar 2019 07:15:32 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/3/12 上午11:50, Michael S. Tsirkin wrote:
>>>> Using direct mapping (I
>>>> guess kernel will always try hugepage for that?) should be better and we can
>>>> even use it for the data transfer not only for the metadata.
>>>>
>>>> Thanks
>>> We can't really. The big issue is get user pages. Doing that on data
>>> path will be slower than copyXuser.
>> I meant if we can find a way to avoid doing gup in datapath. E.g vhost
>> maintain a range tree and add or remove ranges through MMU notifier. Then in
>> datapath, if we find the range, then use direct mapping otherwise
>> copy_to_user().
>>
>> Thanks
> We can try. But I'm not sure there's any reason to think there's any
> locality there.
>

Ok, but what kind of locality do you mean here?

Thanks

