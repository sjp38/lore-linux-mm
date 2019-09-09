Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 392F1C4360D
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 02:29:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 081FE2067B
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 02:29:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 081FE2067B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F7FA6B0005; Sun,  8 Sep 2019 22:29:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 780DE6B0006; Sun,  8 Sep 2019 22:29:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 621686B0007; Sun,  8 Sep 2019 22:29:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0197.hostedemail.com [216.40.44.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3BE1B6B0005
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 22:29:22 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id E420983F7
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 02:29:21 +0000 (UTC)
X-FDA: 75913800522.01.rain70_1779723771129
X-HE-Tag: rain70_1779723771129
X-Filterd-Recvd-Size: 3254
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 02:29:21 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 18DD8309DEEA;
	Mon,  9 Sep 2019 02:29:20 +0000 (UTC)
Received: from [10.72.12.61] (ovpn-12-61.pek2.redhat.com [10.72.12.61])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CC5F760A9D;
	Mon,  9 Sep 2019 02:29:06 +0000 (UTC)
Subject: Re: [PATCH 0/2] Revert and rework on the metadata accelreation
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: "mst@redhat.com" <mst@redhat.com>,
 "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
 "virtualization@lists.linux-foundation.org"
 <virtualization@lists.linux-foundation.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "aarcange@redhat.com" <aarcange@redhat.com>,
 "jglisse@redhat.com" <jglisse@redhat.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>
References: <20190905122736.19768-1-jasowang@redhat.com>
 <20190905135907.GB6011@mellanox.com>
 <7785d39b-b4e7-8165-516c-ee6a08ac9c4e@redhat.com>
 <20190907150330.GC2940@mellanox.com>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <bc1da56e-6256-51a4-57f7-9080099021fb@redhat.com>
Date: Mon, 9 Sep 2019 10:29:04 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190907150330.GC2940@mellanox.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Mon, 09 Sep 2019 02:29:20 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/9/7 =E4=B8=8B=E5=8D=8811:03, Jason Gunthorpe wrote:
> On Fri, Sep 06, 2019 at 06:02:35PM +0800, Jason Wang wrote:
>> On 2019/9/5 =E4=B8=8B=E5=8D=889:59, Jason Gunthorpe wrote:
>>> On Thu, Sep 05, 2019 at 08:27:34PM +0800, Jason Wang wrote:
>>>> Hi:
>>>>
>>>> Per request from Michael and Jason, the metadata accelreation is
>>>> reverted in this version and rework in next version.
>>>>
>>>> Please review.
>>>>
>>>> Thanks
>>>>
>>>> Jason Wang (2):
>>>>     Revert "vhost: access vq metadata through kernel virtual address=
"
>>>>     vhost: re-introducing metadata acceleration through kernel virtu=
al
>>>>       address
>>> There are a bunch of patches in the queue already that will help
>>> vhost, and I a working on one for next cycle that will help alot more
>>> too.
>>
>> I will check those patches, but if you can give me some pointers or ke=
ywords
>> it would be much appreciated.
> You can look here:
>
> https://github.com/jgunthorpe/linux/commits/mmu_notifier
>
> The first parts, the get/put are in the hmm tree, and the last part,
> the interval tree in the last commit is still a WIP, but it would
> remove alot of that code from vhost as well.
>
> Jason


Thanks a lot, will have a look at these and come back if I met any issues=
.


