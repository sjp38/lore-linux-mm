Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3A56C3A59D
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 14:12:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9493C22DD3
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 14:12:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9493C22DD3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 300A26B000A; Tue, 20 Aug 2019 10:12:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B0D46B000D; Tue, 20 Aug 2019 10:12:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 178D76B000E; Tue, 20 Aug 2019 10:12:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0030.hostedemail.com [216.40.44.30])
	by kanga.kvack.org (Postfix) with ESMTP id E4E6F6B000A
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 10:12:03 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 98C53640A
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 14:12:03 +0000 (UTC)
X-FDA: 75842995326.15.pen67_2ee800d04dc34
X-HE-Tag: pen67_2ee800d04dc34
X-Filterd-Recvd-Size: 8962
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 14:12:02 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id EFD48315C02B;
	Tue, 20 Aug 2019 14:12:00 +0000 (UTC)
Received: from [10.18.17.163] (dhcp-17-163.bos.redhat.com [10.18.17.163])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id BFDB75D9CD;
	Tue, 20 Aug 2019 14:11:49 +0000 (UTC)
Subject: Re: [RFC][Patch v12 1/2] mm: page_reporting: core infrastructure
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
 David Hildenbrand <david@redhat.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, virtio-dev@lists.oasis-open.org,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 "Michael S. Tsirkin" <mst@redhat.com>, dodgen@google.com,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com,
 Andrea Arcangeli <aarcange@redhat.com>, john.starks@microsoft.com,
 Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@suse.com>,
 cohuck@redhat.com
References: <20190812131235.27244-1-nitesh@redhat.com>
 <20190812131235.27244-2-nitesh@redhat.com>
 <CAKgT0UcSabyrO=jUwq10KpJKLSuzorHDnKAGrtWVigKVgvD-6Q@mail.gmail.com>
 <b5d4ee25-ae3e-f012-d7f2-7a27d7bbcc54@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <c0e3a4dd-3eab-f00d-6a87-272bb9481dd1@redhat.com>
Date: Tue, 20 Aug 2019 10:11:45 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <b5d4ee25-ae3e-f012-d7f2-7a27d7bbcc54@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Tue, 20 Aug 2019 14:12:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 8/12/19 4:04 PM, Nitesh Narayan Lal wrote:
> On 8/12/19 2:47 PM, Alexander Duyck wrote:
>> On Mon, Aug 12, 2019 at 6:13 AM Nitesh Narayan Lal <nitesh@redhat.com>=
 wrote:
>>> This patch introduces the core infrastructure for free page reporting=
 in
>>> virtual environments. It enables the kernel to track the free pages w=
hich
>>> can be reported to its hypervisor so that the hypervisor could
>>> free and reuse that memory as per its requirement.
>>>
>>> While the pages are getting processed in the hypervisor (e.g.,
>>> via MADV_DONTNEED), the guest must not use them, otherwise, data loss=

>>> would be possible. To avoid such a situation, these pages are
>>> temporarily removed from the buddy. The amount of pages removed
>>> temporarily from the buddy is governed by the backend(virtio-balloon
>>> in our case).
>>>
>>> To efficiently identify free pages that can to be reported to the
>>> hypervisor, bitmaps in a coarse granularity are used. Only fairly big=

>>> chunks are reported to the hypervisor - especially, to not break up T=
HP
>>> in the hypervisor - "MAX_ORDER - 2" on x86, and to save space. The bi=
ts
>>> in the bitmap are an indication whether a page *might* be free, not a=

>>> guarantee. A new hook after buddy merging sets the bits.
>>>
>>> Bitmaps are stored per zone, protected by the zone lock. A workqueue
>>> asynchronously processes the bitmaps, trying to isolate and report pa=
ges
>>> that are still free. The backend (virtio-balloon) is responsible for
>>> reporting these batched pages to the host synchronously. Once reporti=
ng/
>>> freeing is complete, isolated pages are returned back to the buddy.
>>>
>>> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
>> So if I understand correctly the hotplug support for this is still not=

>> included correct?=20
>
> That is correct, I have it as an ongoing-item in my cover-email.
> In case, we decide to go with this approach do you think it is a blocke=
r?

I am planning to defer memory hotplug/hotremove support for the future. D=
ue to
following reasons:
* I would like to first get a basic framework ready and merged (in case w=
e
=C2=A0 decide to go ahead with this approach) and then build on top of it=
=2E
* Memory hotplug/hotremove is not a primary use case in our mind right no=
w and
=C2=A0 hence I am not considering this as a blocker for the first step.

Following are the items which I intend to address before my next submissi=
on:
* Use zone flag and reference counter to track the number of zones reques=
ting
=C2=A0 page reporting.
* Move the bitmap and its respective fields into a structure whose rcu-pr=
otected
=C2=A0 pointer object is maintained on a per-zone basis.
* Pick Alexander's patch for page poisoning support and test them with my=
 patch
=C2=A0 set. (@Alexander: I will keep your signed-off for these patches to=
 indicate
=C2=A0 you are the original author, please do let me know there is a bett=
er way to
=C2=A0 give credit).
* Address other suggestions/comments received on v12.

Looking forward to any suggestions/comments.


[...]
> +
> +       /* assign the configuration object provided by the backend */
> +       rcu_assign_pointer(page_reporting_conf, phconf);
> +
> +out:
> +       mutex_unlock(&page_reporting_mutex);
> +       return ret;
> +}
> +EXPORT_SYMBOL_GPL(page_reporting_enable);
> --
> 2.21.0
>
--=20
Thanks
Nitesh


