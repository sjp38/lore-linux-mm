Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D46EC3A5A9
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 08:40:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2CF6D22DBF
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 08:40:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CF6D22DBF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9CFFB6B0003; Wed,  4 Sep 2019 04:40:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97F6A6B0006; Wed,  4 Sep 2019 04:40:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 870BA6B0007; Wed,  4 Sep 2019 04:40:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0012.hostedemail.com [216.40.44.12])
	by kanga.kvack.org (Postfix) with ESMTP id 6454E6B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 04:40:47 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 09D7C82437C9
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 08:40:47 +0000 (UTC)
X-FDA: 75896592534.25.thumb67_40fc7de87a806
X-HE-Tag: thumb67_40fc7de87a806
X-Filterd-Recvd-Size: 9488
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 08:40:46 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6E57A308FBB4;
	Wed,  4 Sep 2019 08:40:45 +0000 (UTC)
Received: from [10.36.118.26] (unknown [10.36.118.26])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E02495C207;
	Wed,  4 Sep 2019 08:40:27 +0000 (UTC)
Subject: Re: [virtio-dev] Re: [RFC][Patch v12 1/2] mm: page_reporting: core
 infrastructure
To: Nitesh Narayan Lal <nitesh@redhat.com>,
 Alexander Duyck <alexander.duyck@gmail.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, virtio-dev@lists.oasis-open.org,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 Pankaj Gupta <pagupta@redhat.com>, "Wang, Wei W" <wei.w.wang@intel.com>,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 "Michael S. Tsirkin" <mst@redhat.com>, dodgen@google.com,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com,
 Andrea Arcangeli <aarcange@redhat.com>, john.starks@microsoft.com,
 Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@suse.com>,
 cohuck@redhat.com
References: <20190812131235.27244-1-nitesh@redhat.com>
 <20190812131235.27244-2-nitesh@redhat.com>
 <CAKgT0UcSabyrO=jUwq10KpJKLSuzorHDnKAGrtWVigKVgvD-6Q@mail.gmail.com>
 <df82bc99-a212-4f5c-dc2e-28665060acb2@redhat.com>
 <CAKgT0Ueqok+bxANVtB1DdYorcEHN7+Grzb8MAxTzSk8uS81pRA@mail.gmail.com>
 <9a2ffed8-a8a7-a0a6-ec2d-4234b4e11e3e@redhat.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <b298da84-8e73-fcd4-fa93-43537101e30c@redhat.com>
Date: Wed, 4 Sep 2019 10:40:27 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <9a2ffed8-a8a7-a0a6-ec2d-4234b4e11e3e@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Wed, 04 Sep 2019 08:40:45 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

>>> For some reason, I am not seeing this work as I would have expected
>>> but I don't have solid reasoning to share yet. It could be simply
>>> because I am putting my hook at the wrong place. I will continue
>>> investigating this.
>>>
>>> In any case, I may be over complicating things here, so please let me
>>> if there is a better way to do this.
>> I have already been demonstrating the "better way" I think there is to
>> do this. I will push v7 of it early next week unless there is some
>> other feedback. By putting the bit in the page and controlling what
>> comes into and out of the lists it makes most of this quite a bit
>> easier. The only limitation is you have to modify where things get
>> placed in the lists so you don't create a "vapor lock" that would
>> stall the feed of pages into the reporting engine.
>>
>>> If this overhead is not significant we can probably live with it.
>> You have bigger issues you still have to overcome as I recall. Didn't
>> you still need to sort out hotplu
>=20
> For memory hotplug, my impression is that it should
> not be a blocker for taking the first step (in case we do decide to
> go ahead with this approach). Another reason why I am considering
> this as future work is that memory hot(un)plug is still under
> development and requires fixing. (Specifically, issue such as zone
> shrinking which will directly impact the bitmap approach is still
> under discussion).

Memory hotplug is way more reliable than memory unplug - however, but
both are used in production. E.g. the zone shrinking you mention is
something that is not "optimal", but works in most scenarios. So both
features are rather in a "production/fixing" stage than a pure
"development" stage.

However, I do agree that memory hot(un)plug is not something
high-priority for free page hinting in the first shot. If it works out
of the box (Alexander's approach) - great - if not it is just one
additional scenario where free page hinting might not be optimal yet
(like vfio where we can't use it completely right now). After all, most
virtual environment (under KVM) I am aware of don't use DIMM-base memory
hot(un)plug at all.

The important part is that it will not break when memory is added/removed=
.

>=20
>> g and a sparse map with a wide span
>> in a zone? Without those resolved the bitmap approach is still a no-go
>> regardless of performance.
>=20
> For sparsity, the memory wastage should not be significant as I
> am tracking pages on the granularity of (MAX_ORDER - 2) and maintaining
> the bitmaps on a per-zone basis (which was not the case earlier).

To handle sparsity one would have to have separate bitmaps for each
section. Roughly 64 bit per 128MB section. Scanning the scattered bitmap
would get more expensive. Of course, one could have a hierarchical
bitmap to speed up the search etc.

But again, I think we should have a look how much of an issue sparse
zones/nodes actually are in virtual machines (KVM). The setups I am
aware of minimize sparsity (e.g., QEMU will place DIMMs consecutively in
memory, only aligning to e.g, 128MB on x86 if required). Usually all
memory in VMs is onlined to the NORMAL zone (except special cases of
course). The only "issue" would be if you start mixing DIMMs of
different nodes when hotplugging memory. The overhead for 1bit per 2MB
could be almost neglectable in most setups.

But I do agree that for the bitmap-based approach there might be more
scenarios where you'd rather not want to use free page hinting and
instead disable it.

>=20
> However, if you do consider this as a block I will think about it and t=
ry to fix it.
> In the worst case, if I don't find a solution I will add this as a know=
n limitation
> for this approach in my cover.
>=20
>> - Alex


--=20

Thanks,

David / dhildenb

