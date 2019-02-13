Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2180C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 18:41:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8111222D5
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 18:41:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8111222D5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4AACB8E0002; Wed, 13 Feb 2019 13:41:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4309F8E0001; Wed, 13 Feb 2019 13:41:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D2828E0002; Wed, 13 Feb 2019 13:41:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D92DA8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 13:41:54 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 74so2547485pfk.12
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 10:41:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=q62psrd/uVXgouRp8o/VdZg/pZ5EHFNSyMAA2QaEeHc=;
        b=SpQlmUV4GRyToKakZyQPsCsqUiJw1LuDYe4dS2splKyCiR2VzW2Np5oZHIZgeekbCZ
         ltGZBgMNcPGxxn8luV4OnZaQMQMwHaeAisQRpCRlssgbX2Dqwat7qPVAbCna9ZiWK2Or
         0cDcdZewHQeePNwyIQrSxrQd/cU3oGPJnpE9MXtKWoRLrsYHd4CZ1dnMIfs2WZsUuTw8
         /f/uV1n9pdFoT6wXGf9k5Mt8Bs33up5/g7HjQfsMVF8v3x5gBLQRv03t/Yd3zTqtuV/B
         wV0/Ecf6KtTrex4iS/e+PvcpxdCByWSwq8m9wLwSWqPyOZVLi2iIWRHsV1nLHhcgrJxF
         XHaQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuY1wnWOop/kiRJa5UwbgXbEEq5zcplvdLDrOqPmj/J/ifK3OebU
	38cpLU+nTbn0Fe8JE/6ypH083MprXfKgXxmEzr2+aCDjkEmTtMzBQtUPdfKMZV9wMYYH06v/3Mn
	Eh8ubEL7oNMtS6OTexP/klY0Q3MO/ezFVDmIOWOfxDTxP7WqH7VhlSkPSsVpmp5pxFQ==
X-Received: by 2002:a62:1346:: with SMTP id b67mr1859959pfj.195.1550083314494;
        Wed, 13 Feb 2019 10:41:54 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZUhi6iBFEqhmtZd9X9JcSkmVLRvI92nx7WGadWauxcS3jxM5+NUQZ3qHS0hzpZvKsNObsX
X-Received: by 2002:a62:1346:: with SMTP id b67mr1859893pfj.195.1550083313551;
        Wed, 13 Feb 2019 10:41:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550083313; cv=none;
        d=google.com; s=arc-20160816;
        b=xuKyUUS3IbggkoWP9g4B30woLtrf2LooWq/1497FEyAh7ar66TuPNYuHwNlYnuGqZh
         P23wr5UuKlibQAiXZl7Arv1YNqL6hTM6+ZqDKmiRugbJCFM16KK9ZyIEORPrZNU5CctE
         2JbwGnKECOOCAJmj3Ys1oMfY1zSdnlAKjCvHkzFMiXnQtJ72AgagK3tjdTbL6AjqV9k/
         96NRRg5mOhLkpJJqpRpA2SBzjwt2XZNUaniiza3HzZU9iYa2qkS6so+6OSZUq3lGKk8l
         RAua8awtaict6Az2WBrNqcoDXbb4pGKUWBNUlXtllIboZWPnHd7WnPWxDtVXSLTmubYr
         ov9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=q62psrd/uVXgouRp8o/VdZg/pZ5EHFNSyMAA2QaEeHc=;
        b=aiIhH8exGZ38x1cfYTLbn3i4g8p4Or1oqaimhH/1T5WGx4+m0XQ7Dch8KYeKeNDMWY
         wGG9KgQYixE8R7Zh9LdAkjCmhwNa+2hgOD7rHlLiiqIiq2A8Yn8RZsnSrlzqokK+oJvI
         EnpYjW9qOc2BPVgEM3ln47/K+VwBWt59zwuuqPRK4J7w7tp+YZX4tBu4/SfBs9lb789n
         2ezgvtO3jCEtPuLsLi5dmi/KyqEDMPgBcggyvVd5fqf7X/7G1ADesUZ5BeKIFdMNf32L
         W7KL3rKBVQFSD0RsNDLL8CCOlo8f0r8UoFKyffgivfVoV+CVs8Zj9rNxmRTw3oNv5Vbe
         Qocw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c23si13387pls.236.2019.02.13.10.41.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 10:41:53 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1DId7xI096955
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 13:41:52 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qmqanbwej-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 13:41:52 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 13 Feb 2019 18:41:50 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 13 Feb 2019 18:41:45 -0000
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1DIfiac43450398
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Wed, 13 Feb 2019 18:41:44 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B2588AE051;
	Wed, 13 Feb 2019 18:41:44 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 571CBAE053;
	Wed, 13 Feb 2019 18:41:43 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.207.163])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 13 Feb 2019 18:41:43 +0000 (GMT)
Date: Wed, 13 Feb 2019 20:41:40 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Russell King <linux@armlinux.org.uk>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>, Guan Xuetao <gxt@pku.edu.cn>,
        linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
        linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 7/8] initramfs: proide a generic free_initrd_mem
 implementation
References: <20190213174621.29297-1-hch@lst.de>
 <20190213174621.29297-8-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213174621.29297-8-hch@lst.de>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19021318-0028-0000-0000-000003483455
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021318-0029-0000-0000-000024065911
Message-Id: <20190213184139.GC15270@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-13_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902130129
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 06:46:20PM +0100, Christoph Hellwig wrote:
> For most architectures free_initrd_mem just expands to the same
> free_reserved_area call.  Provide that as a generic implementation
> marked __weak.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/alpha/mm/init.c      | 8 --------
>  arch/arc/mm/init.c        | 7 -------
>  arch/c6x/mm/init.c        | 7 -------

csky seems to open-code free_reserved_page with the only
difference that it's also increments totalram_pages for the freed pages,
which doesn't seem correct anyway...

That said, I suppose arch/csky can be also added to the party.

>  arch/h8300/mm/init.c      | 8 --------
>  arch/m68k/mm/init.c       | 7 -------
>  arch/microblaze/mm/init.c | 7 -------
>  arch/nds32/mm/init.c      | 7 -------
>  arch/nios2/mm/init.c      | 7 -------
>  arch/openrisc/mm/init.c   | 7 -------
>  arch/parisc/mm/init.c     | 7 -------
>  arch/powerpc/mm/mem.c     | 7 -------
>  arch/sh/mm/init.c         | 7 -------
>  arch/um/kernel/mem.c      | 7 -------
>  arch/unicore32/mm/init.c  | 7 -------
>  init/initramfs.c          | 5 +++++
>  15 files changed, 5 insertions(+), 100 deletions(-)
 
...

> diff --git a/init/initramfs.c b/init/initramfs.c
> index cf8bf014873f..f3aaa58ac63d 100644
> --- a/init/initramfs.c
> +++ b/init/initramfs.c
> @@ -527,6 +527,11 @@ extern unsigned long __initramfs_size;
>  #include <linux/initrd.h>
>  #include <linux/kexec.h>
> 
> +void __weak free_initrd_mem(unsigned long start, unsigned long end)
> +{
> +	free_reserved_area((void *)start, (void *)end, -1, "initrd");

Some architectures have pr_info("Freeing initrd memory..."), I'd add it for
the generic version as well.

Another thing that I was thinking of is that x86 has all those memory
protection calls in its free_initrd_mem, maybe it'd make sense to have them
in the generic version as well?

> +}
> +
>  #ifdef CONFIG_KEXEC_CORE
>  static bool kexec_free_initrd(void)
>  {
> -- 
> 2.20.1
> 

-- 
Sincerely yours,
Mike.

