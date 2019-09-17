Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35F17C4CECE
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 01:58:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D265F214AF
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 01:58:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="yV7h5TO0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D265F214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 325D76B0003; Mon, 16 Sep 2019 21:58:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D6466B0005; Mon, 16 Sep 2019 21:58:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1ED4C6B0006; Mon, 16 Sep 2019 21:58:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0240.hostedemail.com [216.40.44.240])
	by kanga.kvack.org (Postfix) with ESMTP id EFAA66B0003
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 21:58:24 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 7AE9C812E
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 01:58:24 +0000 (UTC)
X-FDA: 75942752928.28.owl20_495a02c32ed3e
X-HE-Tag: owl20_495a02c32ed3e
X-Filterd-Recvd-Size: 8545
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 01:58:23 +0000 (UTC)
Received: from [192.168.1.112] (c-24-9-64-241.hsd1.co.comcast.net [24.9.64.241])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 004D120678;
	Tue, 17 Sep 2019 01:58:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1568685503;
	bh=bk6B2U84a5RejyELSSMB0s9gF3GyzUbvyJlOCbss36c=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=yV7h5TO0jv/mZK4weNy1RqawMfaZpiR1UnBax+wLu1dpACewB5A/hnnYXUML7rmCk
	 Ucp07G5I7XDYoK/6tP7ubuXhbjjP1ZQY5usW6StqPMH2qanApsnyF3bbIWKLvGHyMN
	 FEsvy7cAj3qrYb4TB4crlTa5PKn1ESzgwFovm2Kg=
Subject: Re: [PATCH v4 9/9] hugetlb_cgroup: Add hugetlb_cgroup reservation
 docs
To: Mina Almasry <almasrymina@google.com>, mike.kravetz@oracle.com
Cc: rientjes@google.com, shakeelb@google.com, gthelen@google.com,
 akpm@linux-foundation.org, khalid.aziz@oracle.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-kselftest@vger.kernel.org, cgroups@vger.kernel.org,
 aneesh.kumar@linux.vnet.ibm.com, mkoutny@suse.com,
 Hillf Danton <hdanton@sina.com>, shuah <shuah@kernel.org>
References: <20190910233146.206080-1-almasrymina@google.com>
 <20190910233146.206080-10-almasrymina@google.com>
From: shuah <shuah@kernel.org>
Message-ID: <9fdff535-5f36-ca91-3905-630c18858170@kernel.org>
Date: Mon, 16 Sep 2019 19:58:20 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190910233146.206080-10-almasrymina@google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/10/19 5:31 PM, Mina Almasry wrote:
> Add docs for how to use hugetlb_cgroup reservations, and their behavior.
> 
> Signed-off-by: Mina Almasry <almasrymina@google.com>
> Acked-by: Hillf Danton <hdanton@sina.com>
> ---
>   .../admin-guide/cgroup-v1/hugetlb.rst         | 84 ++++++++++++++++---
>   1 file changed, 73 insertions(+), 11 deletions(-)
> 
> diff --git a/Documentation/admin-guide/cgroup-v1/hugetlb.rst b/Documentation/admin-guide/cgroup-v1/hugetlb.rst
> index a3902aa253a96..cc6eb859fc722 100644
> --- a/Documentation/admin-guide/cgroup-v1/hugetlb.rst
> +++ b/Documentation/admin-guide/cgroup-v1/hugetlb.rst
> @@ -2,13 +2,6 @@
>   HugeTLB Controller
>   ==================
> 
> -The HugeTLB controller allows to limit the HugeTLB usage per control group and
> -enforces the controller limit during page fault. Since HugeTLB doesn't
> -support page reclaim, enforcing the limit at page fault time implies that,
> -the application will get SIGBUS signal if it tries to access HugeTLB pages
> -beyond its limit. This requires the application to know beforehand how much
> -HugeTLB pages it would require for its use.
> -
>   HugeTLB controller can be created by first mounting the cgroup filesystem.
> 
>   # mount -t cgroup -o hugetlb none /sys/fs/cgroup
> @@ -28,10 +21,14 @@ process (bash) into it.
> 
>   Brief summary of control files::
> 
> - hugetlb.<hugepagesize>.limit_in_bytes     # set/show limit of "hugepagesize" hugetlb usage
> - hugetlb.<hugepagesize>.max_usage_in_bytes # show max "hugepagesize" hugetlb  usage recorded
> - hugetlb.<hugepagesize>.usage_in_bytes     # show current usage for "hugepagesize" hugetlb
> - hugetlb.<hugepagesize>.failcnt		   # show the number of allocation failure due to HugeTLB limit
> + hugetlb.<hugepagesize>.reservation_limit_in_bytes     # set/show limit of "hugepagesize" hugetlb reservations
> + hugetlb.<hugepagesize>.reservation_max_usage_in_bytes # show max "hugepagesize" hugetlb reservations recorded
> + hugetlb.<hugepagesize>.reservation_usage_in_bytes     # show current reservations for "hugepagesize" hugetlb
> + hugetlb.<hugepagesize>.reservation_failcnt            # show the number of allocation failure due to HugeTLB reservation limit
> + hugetlb.<hugepagesize>.limit_in_bytes                 # set/show limit of "hugepagesize" hugetlb faults
> + hugetlb.<hugepagesize>.max_usage_in_bytes             # show max "hugepagesize" hugetlb  usage recorded
> + hugetlb.<hugepagesize>.usage_in_bytes                 # show current usage for "hugepagesize" hugetlb
> + hugetlb.<hugepagesize>.failcnt                        # show the number of allocation failure due to HugeTLB usage limit
> 
>   For a system supporting three hugepage sizes (64k, 32M and 1G), the control
>   files include::
> @@ -40,11 +37,76 @@ files include::
>     hugetlb.1GB.max_usage_in_bytes
>     hugetlb.1GB.usage_in_bytes
>     hugetlb.1GB.failcnt
> +  hugetlb.1GB.reservation_limit_in_bytes
> +  hugetlb.1GB.reservation_max_usage_in_bytes
> +  hugetlb.1GB.reservation_usage_in_bytes
> +  hugetlb.1GB.reservation_failcnt
>     hugetlb.64KB.limit_in_bytes
>     hugetlb.64KB.max_usage_in_bytes
>     hugetlb.64KB.usage_in_bytes
>     hugetlb.64KB.failcnt
> +  hugetlb.64KB.reservation_limit_in_bytes
> +  hugetlb.64KB.reservation_max_usage_in_bytes
> +  hugetlb.64KB.reservation_usage_in_bytes
> +  hugetlb.64KB.reservation_failcnt
>     hugetlb.32MB.limit_in_bytes
>     hugetlb.32MB.max_usage_in_bytes
>     hugetlb.32MB.usage_in_bytes
>     hugetlb.32MB.failcnt
> +  hugetlb.32MB.reservation_limit_in_bytes
> +  hugetlb.32MB.reservation_max_usage_in_bytes
> +  hugetlb.32MB.reservation_usage_in_bytes
> +  hugetlb.32MB.reservation_failcnt
> +
> +
> +1. Reservation limits
> +
> +The HugeTLB controller allows to limit the HugeTLB reservations per control
> +group and enforces the controller limit at reservation time. Reservation limits
> +are superior to Page fault limits (see section 2), since Reservation limits are
> +enforced at reservation time, and never causes the application to get SIGBUS
> +signal. Instead, if the application is violating its limits, then it gets an
> +error on reservation time, i.e. the mmap or shmget return an error.
> +
> +
> +2. Page fault limits
> +
> +The HugeTLB controller allows to limit the HugeTLB usage (page fault) per
> +control group and enforces the controller limit during page fault. Since HugeTLB
> +doesn't support page reclaim, enforcing the limit at page fault time implies
> +that, the application will get SIGBUS signal if it tries to access HugeTLB
> +pages beyond its limit. This requires the application to know beforehand how
> +much HugeTLB pages it would require for its use.
> +
> +
> +3. Caveats with shared memory
> +
> +a. Charging and uncharging:
> +
> +For shared hugetlb memory, both hugetlb reservation and usage (page faults) are
> +charged to the first task that causes the memory to be reserved or faulted,
> +and all subsequent uses of this reserved or faulted memory is done without
> +charging.
> +
> +Shared hugetlb memory is only uncharged when it is unreseved or deallocated.

Spelling?

> +This is usually when the hugetlbfs file is deleted, and not when the task that
> +caused the reservation or fault has exited.
> +
> +b. Interaction between reservation limit and fault limit.
> +
> +Generally, it's not recommended to set both of the reservation limit and fault
> +limit in a cgroup. For private memory, the fault usage cannot exceed the
> +reservation usage, so if you set both, one of those limits will be useless.
> +

Is this enforced? What happens when attempt is made to set fault limit
on a cgroup that has reservation limit and vice versa.

> +For shared memory, a cgroup's fault usage may be greater than its reservation
> +usage, so some care needs to be taken. Consider this example:
> +
> +- Task A reserves 4 pages in a shared hugetlbfs file. Cgroup A will get
> +  4 reservations charged to it and no faults charged to it.
> +- Task B reserves and faults the same 4 pages as Task A. Cgroup B will get no
> +  reservation charge, but will get charged 4 faulted pages. If Cgroup B's limit
> +  is less than 4, then Task B will get a SIGBUS.
> +
> +For the above scenario, it's not recommended for the userspace to set both
> +reservation limits and fault limits, but it is still allowed to in case it sees
> +some use for it.

What would be the scenarios where setting both could be useful? Please 
explain.
> --
> 2.23.0.162.g0b9fbb3734-goog
> 

thanks,
-- Shuah

