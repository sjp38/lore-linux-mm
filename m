Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1FB2C10F0C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 07:40:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB2DF2084D
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 07:40:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB2DF2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F7BB8E0007; Mon, 11 Mar 2019 03:40:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A6C88E0002; Mon, 11 Mar 2019 03:40:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 296EF8E0007; Mon, 11 Mar 2019 03:40:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id EFDB38E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 03:40:46 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id 207so3837696qkf.9
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 00:40:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=5rXlAWgVRhEl7LjQK12ulEwz80Cv5NzpRC7MBEgjgRU=;
        b=CWQ8QfhX3nJ0bucOGTToo2hQ+4Z4X3sgYmb2qIA3/aEV1e0QLBiMop1AcfTJqVTuys
         GMjtN79SQZWYATdGQNJcHBFoBDoG2FCuncd0Po/DFl0enJDvt8SG17p1ORr0WWcRGSEy
         udh9K3kYdEgLD3psj/dBNqv0uQI0CMS+KNMPnwpS1L6+qBkGsASlUEUtFO39QV7FRLCw
         ecOenD3nuqd7Cnh1HTOH9oNEkmXs3+yRFx4iFpcSgN7WwfSWBtVRkRtYGEaPXmx7wuvN
         7RDYSrbCO/D2HFuuFfFsPM/VGfNaHEQklkoF8Cm+k+Wf/kEK6Hyd5xHDpJ+7ZSFma95z
         UZag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVr23LEfkvA42c7t07Kne+41/oXunYQCmqoMVTw0Qdoldw1xZr8
	SeFhRDNTku0whH+ctlI7d8baMrua3j4jOYZVby1ZnjlCKinNSHLfE0fE6ptFC4U2K3EXXbPCdX1
	f5HPcE24Dqn4BYfE4+JlOi9gMCjGKudtloT8D+A+SQUbyS55KuM9n9lBVT1LL92B8HA==
X-Received: by 2002:ac8:faf:: with SMTP id b44mr24807697qtk.9.1552290046746;
        Mon, 11 Mar 2019 00:40:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz7ARSwOK1ZLPnj7YgH0j4yu18ib3miQmSSFd0psvHajPFV1qeCtg04fBGJEPAVVchYxCcf
X-Received: by 2002:ac8:faf:: with SMTP id b44mr24807663qtk.9.1552290045799;
        Mon, 11 Mar 2019 00:40:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552290045; cv=none;
        d=google.com; s=arc-20160816;
        b=sa6MFn4oPkleh2jQLzpT7Sgxvdvq2xnvQn1gSKM+tqSSnhmvwNAOtXv0LhPYv/57em
         2gkNifr0mjE6fnHcNsp5AEn99DTNdXky03HoxQYN6YxQWAybN7u14mNPv/CA5eY4q7HJ
         VJP3EH5cIfk3P0bVG0iSA/jfSNIKWCVqsgs6g91KTXhtci2z+L3LpJeUH9SW6ri0CIHE
         HHbOh1mzukPo15z1lLpR9jH/fjbirUnUYQsADPW6j7NL1Nj2ZoiptHXGRuRqiXquad1Z
         FEb9l839zjaXOW3i6/Q9dLhX8CF7W1iZQZBJnIOcuBx2X/QAj8J+oQ8bWPmnP9aKNivx
         iB6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=5rXlAWgVRhEl7LjQK12ulEwz80Cv5NzpRC7MBEgjgRU=;
        b=xG2i+y4n6diCB62i8DeibpX+8pW9ThU8K7MtGzARa26+QCxW2qmnT72QFFtIDYwwxa
         Im/pPZ+t0psPa5Kxwxn0/ahKG5GjDtd6nUhEygvwB2vFrF3KwoxZmGzqUdrp9c9ANhkW
         yjkE4WRSYx06BDAddeEOyUWmANxwbBizyD6NPK65wyRl/5dt1dvPHgo2YX5MR++CW9wC
         FPk8YTLviF38C43FiXCu2ubg5ibP/Op/bnkCTAkyHpuRF4fdgdJZlVkdyWmm4ct5EnnV
         gvBTZvVOIPObzD3bOo1YEoFr4jf71uVREPEKuLjvMrxfEN2B7jjO191p5taMFOFT+zkC
         ij7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g82si2459610qkb.169.2019.03.11.00.40.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 00:40:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E37F0307E056;
	Mon, 11 Mar 2019 07:40:44 +0000 (UTC)
Received: from [10.72.12.54] (ovpn-12-54.pek2.redhat.com [10.72.12.54])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2A5F260C4E;
	Mon, 11 Mar 2019 07:40:32 +0000 (UTC)
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
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
From: Jason Wang <jasowang@redhat.com>
Message-ID: <8b68a2a0-907a-15f5-a07f-fc5b53d7ea19@redhat.com>
Date: Mon, 11 Mar 2019 15:40:31 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190308194845.GC26923@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Mon, 11 Mar 2019 07:40:44 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/3/9 上午3:48, Andrea Arcangeli wrote:
> Hello Jeson,
>
> On Fri, Mar 08, 2019 at 04:50:36PM +0800, Jason Wang wrote:
>> Just to make sure I understand here. For boosting through huge TLB, do
>> you mean we can do that in the future (e.g by mapping more userspace
>> pages to kenrel) or it can be done by this series (only about three 4K
>> pages were vmapped per virtqueue)?
> When I answered about the advantages of mmu notifier and I mentioned
> guaranteed 2m/gigapages where available, I overlooked the detail you
> were using vmap instead of kmap. So with vmap you're actually doing
> the opposite, it slows down the access because it will always use a 4k
> TLB even if QEMU runs on THP or gigapages hugetlbfs.
>
> If there's just one page (or a few pages) in each vmap there's no need
> of vmap, the linearity vmap provides doesn't pay off in such
> case.
>
> So likely there's further room for improvement here that you can
> achieve in the current series by just dropping vmap/vunmap.
>
> You can just use kmap (or kmap_atomic if you're in preemptible
> section, should work from bh/irq).
>
> In short the mmu notifier to invalidate only sets a "struct page *
> userringpage" pointer to NULL without calls to vunmap.
>
> In all cases immediately after gup_fast returns you can always call
> put_page immediately (which explains why I'd like an option to drop
> FOLL_GET from gup_fast to speed it up).
>
> Then you can check the sequence_counter and inc/dec counter increased
> by _start/_end. That will tell you if the page you got and you called
> put_page to immediately unpin it or even to free it, cannot go away
> under you until the invalidate is called.
>
> If sequence counters and counter tells that gup_fast raced with anyt
> mmu notifier invalidate you can just repeat gup_fast. Otherwise you're
> done, the page cannot go away under you, the host virtual to host
> physical mapping cannot change either. And the page is not pinned
> either. So you can just set the "struct page * userringpage = page"
> where "page" was the one setup by gup_fast.
>
> When later the invalidate runs, you can just call set_page_dirty if
> gup_fast was called with "write = 1" and then you clear the pointer
> "userringpage = NULL".
>
> When you need to read/write to the memory
> kmap/kmap_atomic(userringpage) should work.


Yes, I've considered kmap() from the start. The reason I don't do that 
is large virtqueue may need more than one page so VA might not be 
contiguous. But this is probably not a big issue which just need more 
tricks in the vhost memory accessors.


>
> In short because there's no hardware involvement here, the established
> mapping is just the pointer to the page, there is no need of setting
> up any pagetables or to do any TLB flushes (except on 32bit archs if
> the page is above the direct mapping but it never happens on 64bit
> archs).


I see, I believe we don't care much about the performance of 32bit archs 
(or we can just fallback to copy_to_user() friends). Using direct 
mapping (I guess kernel will always try hugepage for that?) should be 
better and we can even use it for the data transfer not only for the 
metadata.

Thanks


>
> Thanks,
> Andrea

