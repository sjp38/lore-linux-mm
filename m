Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D950C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 12:53:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5107620663
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 12:53:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Ul68qe+l"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5107620663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2B176B0008; Wed,  3 Apr 2019 08:53:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB25B6B000A; Wed,  3 Apr 2019 08:53:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B545C6B000C; Wed,  3 Apr 2019 08:53:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9060C6B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 08:53:42 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id i203so12164855ywa.5
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 05:53:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=NHT9PqacVbcb+iEdSEkiTY4KiJSA+ruLSKxJflNrU5g=;
        b=uJxzomgYI2m2wKDqYxAl3YJKxMwBj9Kyc36bu1c89IPIvQEjkOoOhUbTKN4MZDMP8k
         +7u5tjeEd/oAeQxkwtw7cU1uU0A5BrqHsPKcH3Y7wxXsZtecMPyHlpJ17ci1aVrrzH9S
         gISjUYkgFa79oF1+hcc4YyA+t7IyHI9ityX5PEx9GIbBKrGxNgSywFtgJpcV1b2VxKI6
         72Om28Q1AOo13bjRcYj2GLLzjVv05flJ8/mKSq5pg5aMN9ouTj60mFFA2oR7JOguVygp
         SmAk1AuorC73ugWxtuH338odWYyvWho2MQk7mfwtz3isBHcqPkwXjj+ijkhQ+KisZvWq
         IlYQ==
X-Gm-Message-State: APjAAAVappiE03LH7243G9fZha/mQTqMcDJW+qAZ5R4eweZLKV+Ay05e
	TZnxe+0+0ev+0JPxT1SD6B82EaZUvH9yjXg9HGzzR6Nijg9hOoiJLQbFYj86P2AsL4fA0b8Dxv9
	q7VFsZq9HXyU7p0TsfAmCqxWimHmt/6C0QLuhDpmUqKQAyCeV/r2mi9JSbk9PaqRebw==
X-Received: by 2002:a81:71d5:: with SMTP id m204mr632220ywc.462.1554296022272;
        Wed, 03 Apr 2019 05:53:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtj54t/hmuU3fGhYtLprDKi12yIwljhQ2RnNtC4n4kkYCWzigNu4E2qvWs/yFyvrA0EGx9
X-Received: by 2002:a81:71d5:: with SMTP id m204mr632155ywc.462.1554296021228;
        Wed, 03 Apr 2019 05:53:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554296021; cv=none;
        d=google.com; s=arc-20160816;
        b=txFmK9lHyqlRnba3bksFkJIjHtnM7FqaaeHQg+AFcQ5xyUWOt3mmxDW+JdrUTQ9x0J
         xQcM7Qg90w4LOtBo6jMaDetYbtp+pkIHGjnBAtRn5aUQDEd2eihuG3wt9Np3efsdSBE1
         IPHTyFGdzfZ0RXN8WpU5LbXrTiXHkxANuxYyXozzJaxC45WMW2ONmnNaJ4V0XpKmFewc
         Cz5UZ1enwsb26IHWXZOOQAlRdhwRt5m41aawBfXHxGk/HURNmnnZOpfpJLF4itniz7Dy
         0lRjvSUy4odsN4S0fJV17SM0PmDwBZ64EiCBrdZCogeKV4Q+BunRTPTVbeNE6huRg0oc
         um5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=NHT9PqacVbcb+iEdSEkiTY4KiJSA+ruLSKxJflNrU5g=;
        b=AhTuEbme+vBxYsn7BZPMU246Xk5tq9n8nqbyNnN476pZGHoceLfY0oIeSHL0iANZTh
         GtVqFON945vTSTTckK5aqhHv1e0D6vOr4SdW9rrWltFyAFRbPEEFmroimujXv7gTxckm
         QtElgVoCzRyMJ4ucQu6Mln7jnkfDR4Um5nBq4BxwHpjbB8clfdet+uQWrhup2CkjledH
         b6VazWSQDPrg7NHChoU8O8OPwK+iST9MHdCXN6uZ4Gm2bXJEwyPkJKS9E+0y1BxHB4aM
         hJtAVBguQj0rMDnnzUepzhDUPAJUxoCEv5XfjBd0ObyBVhGPbSvV81DAusSr0ZmAT9c6
         qBog==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Ul68qe+l;
       spf=pass (google.com: domain of steven.sistare@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=steven.sistare@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id a4si10865235ywm.13.2019.04.03.05.53.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 05:53:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.sistare@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Ul68qe+l;
       spf=pass (google.com: domain of steven.sistare@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=steven.sistare@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33ChXe2100938;
	Wed, 3 Apr 2019 12:51:22 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=NHT9PqacVbcb+iEdSEkiTY4KiJSA+ruLSKxJflNrU5g=;
 b=Ul68qe+lCVRnB8QxIbkSLnknGO8ENEkGNFXBYcdNdl49HLsfdL7wxQGQtZVnqZxRnrHt
 mOw3455ycB8dfibQLUWzKyx60JJCSBmHpcBd8VYj9vk2bbSpthszKkxhWxUTZJnAGavK
 pr4/QDDvWxsSiDFQVVmeOJosIbw4NG1hl3h29ap6VBUGtu4AgJxL1ckkTTdVXdrb+d1p
 EenRHGIcBO4W52S1FCoIoFgTJt9ubJ8eE8gg3I80gxVw3gHqLqHMSMscwfxVg73NczAP
 ZqEoI5ilfojmvKUJ5yhSJzowimyc801vAD377rzf4zdeBlXz+bPq9kcK211+i4ZEcpkV 7g== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2130.oracle.com with ESMTP id 2rhyvt8swk-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 12:51:22 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33Co47M064129;
	Wed, 3 Apr 2019 12:51:22 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3030.oracle.com with ESMTP id 2rm8f52vra-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 12:51:22 +0000
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x33CpEC3031705;
	Wed, 3 Apr 2019 12:51:15 GMT
Received: from [10.152.35.85] (/10.152.35.85)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 03 Apr 2019 05:51:14 -0700
Subject: Re: [PATCH 0/6] convert locked_vm from unsigned long to atomic64_t
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: akpm@linux-foundation.org, linux_lkml_grp@oracle.com,
        Alan Tull <atull@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>,
        Alex Williamson <alex.williamson@redhat.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Christoph Lameter <cl@linux.com>, Davidlohr Bueso <dave@stgolabs.net>,
        Michael Ellerman <mpe@ellerman.id.au>, Moritz Fischer <mdf@kernel.org>,
        Paul Mackerras <paulus@ozlabs.org>, Wu Hao <hao.wu@intel.com>,
        linux-mm@kvack.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
        linux-kernel@vger.kernel.org
References: <20190402204158.27582-1-daniel.m.jordan@oracle.com>
From: Steven Sistare <steven.sistare@oracle.com>
Organization: Oracle Corporation
Message-ID: <abe31bae-1bdf-b763-c4d1-5e4ea2ccda13@oracle.com>
Date: Wed, 3 Apr 2019 08:51:13 -0400
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190402204158.27582-1-daniel.m.jordan@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9215 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904030088
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9215 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904030088
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/2/2019 4:41 PM, Daniel Jordan wrote:
> Hi,
> 
> From patch 1:
> 
>   Taking and dropping mmap_sem to modify a single counter, locked_vm, is
>   overkill when the counter could be synchronized separately.
>   
>   Make mmap_sem a little less coarse by changing locked_vm to an atomic,
>   the 64-bit variety to avoid issues with overflow on 32-bit systems.
> 
> This is a more conservative alternative to [1] with no user-visible
> effects.  Thanks to Alexey Kardashevskiy for pointing out the racy
> atomics and to Alex Williamson, Christoph Lameter, Ira Weiny, and Jason
> Gunthorpe for their comments on [1].
> 
> Davidlohr Bueso recently did a similar conversion for pinned_vm[2].
> 
> Testing
>  1. passes LTP mlock[all], munlock[all], fork, mmap, and mremap tests in an
>     x86 kvm guest
>  2. a VFIO-enabled x86 kvm guest shows the same VmLck in
>     /proc/pid/status before and after this change
>  3. cross-compiles on powerpc
> 
> The series is based on v5.1-rc3.  Please consider for 5.2.
> 
> Daniel
> 
> [1] https://lore.kernel.org/linux-mm/20190211224437.25267-1-daniel.m.jordan@oracle.com/
> [2] https://lore.kernel.org/linux-mm/20190206175920.31082-1-dave@stgolabs.net/
> 
> Daniel Jordan (6):
>   mm: change locked_vm's type from unsigned long to atomic64_t
>   vfio/type1: drop mmap_sem now that locked_vm is atomic
>   vfio/spapr_tce: drop mmap_sem now that locked_vm is atomic
>   fpga/dlf/afu: drop mmap_sem now that locked_vm is atomic
>   powerpc/mmu: drop mmap_sem now that locked_vm is atomic
>   kvm/book3s: drop mmap_sem now that locked_vm is atomic
> 
>  arch/powerpc/kvm/book3s_64_vio.c    | 34 ++++++++++--------------
>  arch/powerpc/mm/mmu_context_iommu.c | 28 +++++++++-----------
>  drivers/fpga/dfl-afu-dma-region.c   | 40 ++++++++++++-----------------
>  drivers/vfio/vfio_iommu_spapr_tce.c | 37 ++++++++++++--------------
>  drivers/vfio/vfio_iommu_type1.c     | 31 +++++++++-------------
>  fs/proc/task_mmu.c                  |  2 +-
>  include/linux/mm_types.h            |  2 +-
>  kernel/fork.c                       |  2 +-
>  mm/debug.c                          |  5 ++--
>  mm/mlock.c                          |  4 +--
>  mm/mmap.c                           | 18 ++++++-------
>  mm/mremap.c                         |  6 ++---
>  12 files changed, 89 insertions(+), 120 deletions(-)
> 
> base-commit: 79a3aaa7b82e3106be97842dedfd8429248896e6

Hi Daniel,
  You could clean all 6 patches up nicely with a common subroutine that
increases locked_vm subject to the rlimit.  Pass a bool arg that is true if
the  limit should be enforced, !dma->lock_cap for one call site, and
!capable(CAP_IPC_LOCK) for the rest.  Push the warnings and debug statements
to the subroutine as well.  One patch could refactor, and a second could
change the locking method.

- Steve

