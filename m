Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3BD2C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 02:59:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D2A02087C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 02:59:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D2A02087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C5008E0003; Mon, 11 Mar 2019 22:59:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 074F38E0002; Mon, 11 Mar 2019 22:59:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECC7D8E0003; Mon, 11 Mar 2019 22:59:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id C69758E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 22:59:27 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id y6so1097986qke.1
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 19:59:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=4RMQWPAMpHHEUsyi0oRyYWILxzph9kEGlvcBgxtLSvg=;
        b=AxIq7cdvY79ttOFU5kv4T0GMil0jb5zblgsdHUAwH38U4JfO7fWt0bf6SM3k82qSSx
         ZCVD8ZrvNrGuwNYpamTKYHLLTYtfZdXjgl1m2gh+0g2h+5mmeIeHgBYWxakFP8wE7Hii
         ZSE4ilJBDA3TA0h8P7xAyV2bXMUTkpovMJ/0vQrr8HjUPpaiatBerJ8uczGc7gcCLs3h
         o/fGnIrmC6GofJ7kqGoDQvtJa8J5tOD47N0HjmSGy2TnMOijBLT+B5RBC9TYP6hp0HH4
         wCMpuU32PaBmcstRW6WhOJdW+7Aw/V9Gw1pzq4TLPpFrU0U1ErttIxDHj/SAiw0lVICu
         TSdQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUhL8fENM0yk4YIKHFzHL1MBgzOoSDSd026dMpEF+775dzFDQ92
	ik7qZd/Zvfo8niF3/8gobpNxRQl4VHfDWjPlGjv1w93mAAsA/OxTZR12/EYHLeW6Cd9xGIZbT3s
	lmCfbT9eVmKfYcOl0A7/zD/hA9kpeDs/PMLPMvDLHObp8j4kyWInFSStE1IrapS4RfA==
X-Received: by 2002:ac8:3f46:: with SMTP id w6mr29060149qtk.175.1552359567614;
        Mon, 11 Mar 2019 19:59:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwiqq1W4tLdCqQeSvpzmbfOn9WMH2pOYueTcTxHYAAO+kYNa19vccOjc2vY6EQljSryFkZ8
X-Received: by 2002:ac8:3f46:: with SMTP id w6mr29060121qtk.175.1552359566808;
        Mon, 11 Mar 2019 19:59:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552359566; cv=none;
        d=google.com; s=arc-20160816;
        b=JbRGfK77Li6Dz1AisYxp9GNUI+3YReLjZx5PV6l71qVNyULKyQvFB6J5+cPqKgTA/Q
         hxu836htLGmR4HJsAk/iHnhk6xjKpU6Nf5PNLLU0/0A2VjZvz8vppVeE+pVpaSb+oLNs
         a1LmoOFGC9n7BJxeuJvMKoLuajwrE4IC4oufvG71jtXgRex02fWTK3Ph5A+7zyttwNep
         kCjqYlS1V5jCFXR5ngPdWu/C9lrWeZKfw3DfnsGB9E1zn99gwHC7taHdAE0n+XLFTFSl
         JTXHFi1JJOlmPwa53k9t47CPK0B5QieN+3JwRi+gq0YFEeCYEsB+T6S+ZkhD6pvbepIs
         wfwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=4RMQWPAMpHHEUsyi0oRyYWILxzph9kEGlvcBgxtLSvg=;
        b=lThwL2Omd0STAlSPTk+mvJZdPNbgttlwlOCzA/0XSu/W+No2B6SbRlI6XOT8MEfg3Y
         58nElDe0USUDkOkzDSWCwZqilU3mB2OZhjfACuuzpWXU/rt4s0FLC7hWpRQ93cnANmI+
         9/RQ1sB4TALkI09FRQd89IpiH9lsPmEqAz8iQ+cOd4R2kcdG8Xa7pvrt9uSsmHro2bPc
         FRKKE12x/8JStVn+Kcyy0dAU851j/7XVrS5qArF6fcBW/FrQI0buXc9o6ag7SVBGXAar
         93PPoKiBtd95/uAsH+l04yxe9hNGX82AqHqo4jsnphe/TTLleOxfvGpveoV0Es/UOp2E
         628g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l12si481974qtq.216.2019.03.11.19.59.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 19:59:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CC3BE307CDF5;
	Tue, 12 Mar 2019 02:59:25 +0000 (UTC)
Received: from [10.72.12.17] (ovpn-12-17.pek2.redhat.com [10.72.12.17])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 63C4660C4C;
	Tue, 12 Mar 2019 02:59:14 +0000 (UTC)
Subject: Re: [RFC PATCH V2 0/5] vhost: accelerate metadata access through
 vmap()
To: David Miller <davem@davemloft.net>, mst@redhat.com
Cc: hch@infradead.org, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
 aarcange@redhat.com, linux-arm-kernel@lists.infradead.org,
 linux-parisc@vger.kernel.org
References: <20190308141220.GA21082@infradead.org>
 <56374231-7ba7-0227-8d6d-4d968d71b4d6@redhat.com>
 <20190311095405-mutt-send-email-mst@kernel.org>
 <20190311.111413.1140896328197448401.davem@davemloft.net>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <6b6dcc4a-2f08-ba67-0423-35787f3b966c@redhat.com>
Date: Tue, 12 Mar 2019 10:59:09 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190311.111413.1140896328197448401.davem@davemloft.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Tue, 12 Mar 2019 02:59:26 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/3/12 上午2:14, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Mon, 11 Mar 2019 09:59:28 -0400
>
>> On Mon, Mar 11, 2019 at 03:13:17PM +0800, Jason Wang wrote:
>>> On 2019/3/8 下午10:12, Christoph Hellwig wrote:
>>>> On Wed, Mar 06, 2019 at 02:18:07AM -0500, Jason Wang wrote:
>>>>> This series tries to access virtqueue metadata through kernel virtual
>>>>> address instead of copy_user() friends since they had too much
>>>>> overheads like checks, spec barriers or even hardware feature
>>>>> toggling. This is done through setup kernel address through vmap() and
>>>>> resigter MMU notifier for invalidation.
>>>>>
>>>>> Test shows about 24% improvement on TX PPS. TCP_STREAM doesn't see
>>>>> obvious improvement.
>>>> How is this going to work for CPUs with virtually tagged caches?
>>>
>>> Anything different that you worry?
>> If caches have virtual tags then kernel and userspace view of memory
>> might not be automatically in sync if they access memory
>> through different virtual addresses. You need to do things like
>> flush_cache_page, probably multiple times.
> "flush_dcache_page()"


I get this. Then I think the current set_bit_to_user() is suspicious, we 
probably miss a flush_dcache_page() there:


static int set_bit_to_user(int nr, void __user *addr)
{
         unsigned long log = (unsigned long)addr;
         struct page *page;
         void *base;
         int bit = nr + (log % PAGE_SIZE) * 8;
         int r;

         r = get_user_pages_fast(log, 1, 1, &page);
         if (r < 0)
                 return r;
         BUG_ON(r != 1);
         base = kmap_atomic(page);
         set_bit(bit, base);
         kunmap_atomic(base);
         set_page_dirty_lock(page);
         put_page(page);
         return 0;
}

Thanks

