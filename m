Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA8A5C5ACAE
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 16:01:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6147220872
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 16:01:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="fP8AO1YE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6147220872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF02D6B0005; Wed, 11 Sep 2019 12:01:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA0BF6B0007; Wed, 11 Sep 2019 12:01:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C677D6B0010; Wed, 11 Sep 2019 12:01:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0132.hostedemail.com [216.40.44.132])
	by kanga.kvack.org (Postfix) with ESMTP id A06C26B0005
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 12:01:46 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 0E8431F870
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 16:01:46 +0000 (UTC)
X-FDA: 75923105412.05.crib38_66a8de8bce556
X-HE-Tag: crib38_66a8de8bce556
X-Filterd-Recvd-Size: 7746
Received: from mail-qt1-f193.google.com (mail-qt1-f193.google.com [209.85.160.193])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 16:01:45 +0000 (UTC)
Received: by mail-qt1-f193.google.com with SMTP id c17so6528647qtv.9
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 09:01:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=SzFYnOnqYRRD6oxfohm7GaTRApau1VSO8et7sdvAxw4=;
        b=fP8AO1YEJfmo1iSSlsVCCw128xF/ewA8VemLrD++gV3EuoRdYfWj5LGmMLdu19lK4s
         9zlJY92ZHUnz8AH9KmdUzzjMuRJkhMtseQEihRbLApkujfj9Oacj8sSEv0S9bp5m5L2P
         0s0HfThhl6kHvvwdsCAzApVOD5G+ChCuptHjBZjkPs/npao4zDC+Uk+EQGQ7BXiP8NFk
         zZuMrvwi5ek2GUs/E7YBQJsP8kx9aDaANfBUgpE23o4kmuy2S/lBVl52ydKaTkzFcbvk
         cnNRSTf2/N88bVMUqK/e3TinHy4A7UR1PGtMx2yWphZeeekzfos9ZbSMyrUX84rCLBNX
         16rg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=SzFYnOnqYRRD6oxfohm7GaTRApau1VSO8et7sdvAxw4=;
        b=l+lGcVoYUSUVsvv4pSZ6uXsnJIxfZF4EbxpinDtkDGrIqNeHBiV1Q/XEkq9L19CKoo
         Q4vuxrk2z/fdae8AnQMVbA2Wukfau/IjwhlH8RDnr+KIET6VqbUVxDFFbQoy9z3VH8AD
         VMU0cv9hFeGzMlUnKX0qG7POwy/r9DiN4ZuL7lcHuSGJWtPKRUNlqMXBM/3fqTv5u9vt
         15n0SgFgdb5BUTmGW9xzy4llgAQaZ4UHihkhzr6gkb9lHuUcb+0GHNpet3QkBYd3xVEX
         7zJEHBoUAZh+LiYvpOJTkMbyHb+V/RLfqqgFj3beDl0R+u7/tVbmVNktoDkG+P4D5u1i
         nH0Q==
X-Gm-Message-State: APjAAAVhBztLlYyiuX3xoX7V404nHFINdt6pbTbYSqCVC/Vrgto4QJSv
	qsj38Un4pCRD+5aFUXmESVahyg==
X-Google-Smtp-Source: APXvYqyPRa3MTbsa/Kmfswg0Bvkx67oWrfiDmXUWdRKwYuZ+uMqrlFSoglXlepuG5gVaVEYCQcG8yg==
X-Received: by 2002:ac8:546:: with SMTP id c6mr11563196qth.151.1568217704576;
        Wed, 11 Sep 2019 09:01:44 -0700 (PDT)
Received: from [192.168.1.153] (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id l22sm8529363qtp.8.2019.09.11.09.01.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Sep 2019 09:01:44 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: [PATCH 5/5] hugetlbfs: Limit wait time when trying to share huge
 PMD
From: Qian Cai <cai@lca.pw>
In-Reply-To: <20190911150537.19527-6-longman@redhat.com>
Date: Wed, 11 Sep 2019 12:01:42 -0400
Cc: Peter Zijlstra <peterz@infradead.org>,
 Ingo Molnar <mingo@redhat.com>,
 Will Deacon <will.deacon@arm.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Mike Kravetz <mike.kravetz@oracle.com>,
 linux-kernel@vger.kernel.org,
 linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org,
 Davidlohr Bueso <dave@stgolabs.net>
Content-Transfer-Encoding: quoted-printable
Message-Id: <B97932F4-7A2D-4265-9BB2-BF6E19B45DB7@lca.pw>
References: <20190911150537.19527-1-longman@redhat.com>
 <20190911150537.19527-6-longman@redhat.com>
To: Waiman Long <longman@redhat.com>
X-Mailer: Apple Mail (2.3445.104.11)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Sep 11, 2019, at 11:05 AM, Waiman Long <longman@redhat.com> wrote:
>=20
> When allocating a large amount of static hugepages (~500-1500GB) on a
> system with large number of CPUs (4, 8 or even 16 sockets), =
performance
> degradation (random multi-second delays) was observed when thousands
> of processes are trying to fault in the data into the huge pages. The
> likelihood of the delay increases with the number of sockets and hence
> the CPUs a system has.  This only happens in the initial setup phase
> and will be gone after all the necessary data are faulted in.
>=20
> These random delays, however, are deemed unacceptable. The cause of
> that delay is the long wait time in acquiring the mmap_sem when trying
> to share the huge PMDs.
>=20
> To remove the unacceptable delays, we have to limit the amount of wait
> time on the mmap_sem. So the new down_write_timedlock() function is
> used to acquire the write lock on the mmap_sem with a timeout value of
> 10ms which should not cause a perceivable delay. If timeout happens,
> the task will abandon its effort to share the PMD and allocate its own
> copy instead.
>=20
> When too many timeouts happens (threshold currently set at 256), the
> system may be too large for PMD sharing to be useful without undue =
delay.
> So the sharing will be disabled in this case.
>=20
> Signed-off-by: Waiman Long <longman@redhat.com>
> ---
> include/linux/fs.h |  7 +++++++
> mm/hugetlb.c       | 24 +++++++++++++++++++++---
> 2 files changed, 28 insertions(+), 3 deletions(-)
>=20
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 997a530ff4e9..e9d3ad465a6b 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -40,6 +40,7 @@
> #include <linux/fs_types.h>
> #include <linux/build_bug.h>
> #include <linux/stddef.h>
> +#include <linux/ktime.h>
>=20
> #include <asm/byteorder.h>
> #include <uapi/linux/fs.h>
> @@ -519,6 +520,12 @@ static inline void i_mmap_lock_write(struct =
address_space *mapping)
> 	down_write(&mapping->i_mmap_rwsem);
> }
>=20
> +static inline bool i_mmap_timedlock_write(struct address_space =
*mapping,
> +					 ktime_t timeout)
> +{
> +	return down_write_timedlock(&mapping->i_mmap_rwsem, timeout);
> +}
> +
> static inline void i_mmap_unlock_write(struct address_space *mapping)
> {
> 	up_write(&mapping->i_mmap_rwsem);
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 6d7296dd11b8..445af661ae29 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4750,6 +4750,8 @@ void adjust_range_if_pmd_sharing_possible(struct =
vm_area_struct *vma,
> 	}
> }
>=20
> +#define PMD_SHARE_DISABLE_THRESHOLD	(1 << 8)
> +
> /*
>  * Search for a shareable pmd page for hugetlb. In any case calls =
pmd_alloc()
>  * and returns the corresponding pte. While this is not necessary for =
the
> @@ -4770,11 +4772,24 @@ pte_t *huge_pmd_share(struct mm_struct *mm, =
unsigned long addr, pud_t *pud)
> 	pte_t *spte =3D NULL;
> 	pte_t *pte;
> 	spinlock_t *ptl;
> +	static atomic_t timeout_cnt;
>=20
> -	if (!vma_shareable(vma, addr))
> -		return (pte_t *)pmd_alloc(mm, pud, addr);
> +	/*
> +	 * Don't share if it is not sharable or locking attempt timed =
out
> +	 * after 10ms. After 256 timeouts, PMD sharing will be =
permanently
> +	 * disabled as it is just too slow.

It looks like this kind of policy interacts with kernel debug options =
like KASAN (which is going to slow the system down
anyway) could introduce tricky issues due to different timings on a =
debug kernel.

> +	 */
> +	if (!vma_shareable(vma, addr) ||
> +	   (atomic_read(&timeout_cnt) >=3D PMD_SHARE_DISABLE_THRESHOLD))
> +		goto out_no_share;
> +
> +	if (!i_mmap_timedlock_write(mapping, ms_to_ktime(10))) {
> +		if (atomic_inc_return(&timeout_cnt) =3D=3D
> +		    PMD_SHARE_DISABLE_THRESHOLD)
> +			pr_info("Hugetlbfs PMD sharing disabled because =
of timeouts!\n");
> +		goto out_no_share;
> +	}
>=20
> -	i_mmap_lock_write(mapping);
> 	vma_interval_tree_foreach(svma, &mapping->i_mmap, idx, idx) {
> 		if (svma =3D=3D vma)
> 			continue;
> @@ -4806,6 +4821,9 @@ pte_t *huge_pmd_share(struct mm_struct *mm, =
unsigned long addr, pud_t *pud)
> 	pte =3D (pte_t *)pmd_alloc(mm, pud, addr);
> 	i_mmap_unlock_write(mapping);
> 	return pte;
> +
> +out_no_share:
> +	return (pte_t *)pmd_alloc(mm, pud, addr);
> }
>=20
> /*
> --=20
> 2.18.1
>=20
>=20


