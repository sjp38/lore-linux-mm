Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1AFCBC43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 07:18:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CAAE8206DF
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 07:18:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CAAE8206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 543958E0005; Mon, 11 Mar 2019 03:18:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F0A48E0002; Mon, 11 Mar 2019 03:18:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 393968E0005; Mon, 11 Mar 2019 03:18:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0C9298E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 03:18:58 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id s65so3772340qke.16
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 00:18:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=0N0MCzbqKLckB8paK8BbPHeqmptaEykOTPPNGejF6jQ=;
        b=ZHlomqZtPBH3n2+wleCrz8/hUNEHMWaaI1s/p+5dXTqDnkCqLlMvFQvWSu0JH4zSe8
         oLLketH2TOvuJL+9iCYoxRNpOCrMtV5nbM+xmAQ03A0kQcKJ/oIXqmYMKFZ6zb4sNq/H
         XZXJjJeevsadvWm+Qb08/QI9X5pxGw42To/4Oyh/TbYXyR1PI3VSJBMpLFBzU7tvtPlz
         FBggEAy87tPaYJnytCkc1O2j7Ufm9VlQL8Go95zQ+iw5Pcn1c1r0W0ymYzwGDdz6Ucy3
         fFxEr3VhpuYz5+FYY8wNim7JzoGgzdAFtyrHYvEzUzKsa+oivwgKg5+Aan/k2Fof9Qu8
         RGDw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUnI1PcwcaF0zPoDvWCBlH4C6mRaT2QxVYgOqmZVUjZ4FmKzZZ/
	DCgv9nHi7PTJ5qoVNDjMUpTq+ppZKrSlODbI2mzt/xbtwfJvcplCfXua0gftFw+52ONh9BHgQIK
	LyKfvqg1SFrk0iCbxwIxnH3Sc7We/W1CDUDUvfOK2M/oTpezT3LA/v6jIiB01/ytMNg==
X-Received: by 2002:ac8:2314:: with SMTP id a20mr24777666qta.127.1552288737813;
        Mon, 11 Mar 2019 00:18:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqytJ7ZRZbH4M88O2hqHCubYhmZ8YOVlASVX/uOwzBDdt30YND1E3LoAVh2E3egwtI+SRGjb
X-Received: by 2002:ac8:2314:: with SMTP id a20mr24777634qta.127.1552288737043;
        Mon, 11 Mar 2019 00:18:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552288737; cv=none;
        d=google.com; s=arc-20160816;
        b=cXQ//KpSvaZ5TCNNm5hysSHbcMwcNiC4qubb7qhf8wQ0KqrNK92UMz0hTcdBTIU2kd
         hVJoW8J0v7ztRUsGkLIZsbxcVIAcB/9zqOxK5b5nkNWq86YR9g+37DnAE7X5CXk1aXOD
         aLM/c+urtp/2UvyqHEqQ9iJhOJZRu0wk5ek3k0q7W0WKztirZRPJxAJNptI9HTX8KcOY
         3dAvPZj2PAnSWvUINul+hJfavGMcDPb7fN0LHP1BKwRiBTQoaQR48tCqur9ccY+Ee5Nk
         U4Qik0xCJh0bMJXTazk9cREjOWfd36QzDUu9a0+cMr/4XApJmQNyslPV2a8N/PXK9tYb
         Xa7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=0N0MCzbqKLckB8paK8BbPHeqmptaEykOTPPNGejF6jQ=;
        b=fuY0fmJC1LH5dTBTt8QqXItatdAN8Wf+/dD/AQ1CX6jU4FH8rxYHhYDfjs3YkcWUFK
         TVqZllPtneSmcktlgCzeoEJl9CTYWxqEoDsHD8wp2jKCMefkJsW3e983YqLwQQzaJebP
         C2hOzSa95mHD0PWpRPhFrtQl8gbwsxzsWG3fRDZ8Xt1Mmcz3Lv3AiFQYcPoi1l7eeCZL
         0eSC8+1Uq8ev25EzE1QREUDso71Vbwox4WkbvrMlM1XFOXaqMMfqiO81NSoqxeKC1T1F
         U1JPONmmax44rSYStTcKRmpC1/sM9qRsMs5F+K9T3FPjQ73yRfvqrIrFFzos+OUUbm+v
         G0Hw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g4si1941628qto.287.2019.03.11.00.18.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 00:18:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 29AFA368B1;
	Mon, 11 Mar 2019 07:18:56 +0000 (UTC)
Received: from [10.72.12.54] (ovpn-12-54.pek2.redhat.com [10.72.12.54])
	by smtp.corp.redhat.com (Postfix) with ESMTP id F137E600CC;
	Mon, 11 Mar 2019 07:18:47 +0000 (UTC)
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 "Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190307103503-mutt-send-email-mst@kernel.org>
 <20190307124700-mutt-send-email-mst@kernel.org>
 <20190307191622.GP23850@redhat.com>
 <e2fad6ed-9257-b53c-394b-bc913fc444c0@redhat.com>
 <20190308145800.GA3661@redhat.com>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <109b40c3-61d4-42f2-5914-ab8433a70ef1@redhat.com>
Date: Mon, 11 Mar 2019 15:18:46 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190308145800.GA3661@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Mon, 11 Mar 2019 07:18:56 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/3/8 下午10:58, Jerome Glisse wrote:
> On Fri, Mar 08, 2019 at 04:50:36PM +0800, Jason Wang wrote:
>> On 2019/3/8 上午3:16, Andrea Arcangeli wrote:
>>> On Thu, Mar 07, 2019 at 12:56:45PM -0500, Michael S. Tsirkin wrote:
>>>> On Thu, Mar 07, 2019 at 10:47:22AM -0500, Michael S. Tsirkin wrote:
>>>>> On Wed, Mar 06, 2019 at 02:18:12AM -0500, Jason Wang wrote:
>>>>>> +static const struct mmu_notifier_ops vhost_mmu_notifier_ops = {
>>>>>> +	.invalidate_range = vhost_invalidate_range,
>>>>>> +};
>>>>>> +
>>>>>>    void vhost_dev_init(struct vhost_dev *dev,
>>>>>>    		    struct vhost_virtqueue **vqs, int nvqs, int iov_limit)
>>>>>>    {
>>>>> I also wonder here: when page is write protected then
>>>>> it does not look like .invalidate_range is invoked.
>>>>>
>>>>> E.g. mm/ksm.c calls
>>>>>
>>>>> mmu_notifier_invalidate_range_start and
>>>>> mmu_notifier_invalidate_range_end but not mmu_notifier_invalidate_range.
>>>>>
>>>>> Similarly, rmap in page_mkclean_one will not call
>>>>> mmu_notifier_invalidate_range.
>>>>>
>>>>> If I'm right vhost won't get notified when page is write-protected since you
>>>>> didn't install start/end notifiers. Note that end notifier can be called
>>>>> with page locked, so it's not as straight-forward as just adding a call.
>>>>> Writing into a write-protected page isn't a good idea.
>>>>>
>>>>> Note that documentation says:
>>>>> 	it is fine to delay the mmu_notifier_invalidate_range
>>>>> 	call to mmu_notifier_invalidate_range_end() outside the page table lock.
>>>>> implying it's called just later.
>>>> OK I missed the fact that _end actually calls
>>>> mmu_notifier_invalidate_range internally. So that part is fine but the
>>>> fact that you are trying to take page lock under VQ mutex and take same
>>>> mutex within notifier probably means it's broken for ksm and rmap at
>>>> least since these call invalidate with lock taken.
>>> Yes this lock inversion needs more thoughts.
>>>
>>>> And generally, Andrea told me offline one can not take mutex under
>>>> the notifier callback. I CC'd Andrea for why.
>>> Yes, the problem then is the ->invalidate_page is called then under PT
>>> lock so it cannot take mutex, you also cannot take the page_lock, it
>>> can at most take a spinlock or trylock_page.
>>>
>>> So it must switch back to the _start/_end methods unless you rewrite
>>> the locking.
>>>
>>> The difference with _start/_end, is that ->invalidate_range avoids the
>>> _start callback basically, but to avoid the _start callback safely, it
>>> has to be called in between the ptep_clear_flush and the set_pte_at
>>> whenever the pfn changes like during a COW. So it cannot be coalesced
>>> in a single TLB flush that invalidates all sptes in a range like we
>>> prefer for performance reasons for example in KVM. It also cannot
>>> sleep.
>>>
>>> In short ->invalidate_range must be really fast (it shouldn't require
>>> to send IPI to all other CPUs like KVM may require during an
>>> invalidate_range_start) and it must not sleep, in order to prefer it
>>> to _start/_end.
>>>
>>> I.e. the invalidate of the secondary MMU that walks the linux
>>> pagetables in hardware (in vhost case with GUP in software) has to
>>> happen while the linux pagetable is zero, otherwise a concurrent
>>> hardware pagetable lookup could re-instantiate a mapping to the old
>>> page in between the set_pte_at and the invalidate_range_end (which
>>> internally calls ->invalidate_range). Jerome documented it nicely in
>>> Documentation/vm/mmu_notifier.rst .
>>
>> Right, I've actually gone through this several times but some details were
>> missed by me obviously.
>>
>>
>>> Now you don't really walk the pagetable in hardware in vhost, but if
>>> you use gup_fast after usemm() it's similar.
>>>
>>> For vhost the invalidate would be really fast, there are no IPI to
>>> deliver at all, the problem is just the mutex.
>>
>> Yes. A possible solution is to introduce a valid flag for VA. Vhost may only
>> try to access kernel VA when it was valid. Invalidate_range_start() will
>> clear this under the protection of the vq mutex when it can block. Then
>> invalidate_range_end() then can clear this flag. An issue is blockable is
>> always false for range_end().
>>
> Note that there can be multiple asynchronous concurrent invalidate_range
> callbacks. So a flag does not work but a counter of number of active
> invalidation would. See how KSM is doing it for instance in kvm_main.c
>
> The pattern for this kind of thing is:
>      my_invalidate_range_start(start,end) {
>          ...
>          if (mystruct_overlap(mystruct, start, end)) {
>              mystruct_lock();
>              mystruct->invalidate_count++;
>              ...
>              mystruct_unlock();
>          }
>      }
>
>      my_invalidate_range_end(start,end) {
>          ...
>          if (mystruct_overlap(mystruct, start, end)) {
>              mystruct_lock();
>              mystruct->invalidate_count--;
>              ...
>              mystruct_unlock();
>          }
>      }
>
>      my_access_va(mystruct) {
>      again:
>          wait_on(!mystruct->invalidate_count)
>          mystruct_lock();
>          if (mystruct->invalidate_count) {
>              mystruct_unlock();
>              goto again;
>          }
>          GUP();
>          ...
>          mystruct_unlock();
>      }
>
> Cheers,
> Jérôme


Yes, this should work.

Thanks

