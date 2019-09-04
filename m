Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E451C3A59E
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 22:11:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F279020820
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 22:11:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="FbVvAa4Z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F279020820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 799576B0003; Wed,  4 Sep 2019 18:11:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 74AC76B0006; Wed,  4 Sep 2019 18:11:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6378B6B0007; Wed,  4 Sep 2019 18:11:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0254.hostedemail.com [216.40.44.254])
	by kanga.kvack.org (Postfix) with ESMTP id 42E696B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 18:11:46 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id D2E29824CA24
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 22:11:45 +0000 (UTC)
X-FDA: 75898636170.04.sort04_f2f4b4deae62
X-HE-Tag: sort04_f2f4b4deae62
X-Filterd-Recvd-Size: 11620
Received: from mail-ot1-f67.google.com (mail-ot1-f67.google.com [209.85.210.67])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 22:11:44 +0000 (UTC)
Received: by mail-ot1-f67.google.com with SMTP id y39so94024ota.7
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 15:11:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=4kE3lZ/Bwg6OZFmdqJYo1FBMdfISdZagSxNgCKkOWkU=;
        b=FbVvAa4Z1/dvnMv0Fx/FpWcq+MlXqxUWGVghGf+z/rlr8Yfb4r5jGDBhUpcDQsRO7r
         7Jj5Rof1WZJtA0AfwNknyl8f9/K7hT5sdthHDESksc1egMNU3kVJcO+lY9GdtPX7wrQh
         oBGl28oevStQ4dFjo/M9gKdav43EIXwITZSFVupNam+BVUJzhS7aejdxfXZuOiOI+wOy
         ChETaBhveS51VVkf/xIy84mmc9nQVwDE5b49MaHbtmCDfQd5dGT2RJtIjc9GBEzSw8M8
         8jDFRQ5/54Dr90u4qaRU2Tb7p4OUgSWzWA2VPGFisa5H6zoLQpnqLpuLd4AM1ib87se9
         TJ+A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=4kE3lZ/Bwg6OZFmdqJYo1FBMdfISdZagSxNgCKkOWkU=;
        b=LrTwqxyfe4FLBbMr+8Hjr9+zhTQiZuCtQTnQbiVXOC5HoS9tAEoP8NP0A7arOaaomd
         Gg/Gzm4mh7lP5mglNiMsj6mc2+CkX9fRchrKY9Ad9nzN6VJe1eEqzgbeIS+1st50iTCb
         sYndnYRx41Dz/o5N3MGbgituSD6JTE1li1+GJ6um7I0jvHLScp/Wn4+wIvvSnpw1hJp7
         35GN+tyjDSrdxJPbeBgNPTNvqrgGilYo8XctF9eyuY6a3Uzi3cLYpdkMjL1y+jtNTKOh
         2L+MivgYP7g58CKrx0+GZY2qK6epMoXNHsxsc38MlT7zvHDYXirIm7x6k4EdauOSVIJr
         2jXw==
X-Gm-Message-State: APjAAAUfjS7tWESRo+jfT/9uqdeRMcDKN+DvCeQfSoQMx+udCrmAD4Vk
	nK6uSfdZUjhYmRKec1VK6VxTYfqhy7SwEQdZ7/Zskw==
X-Google-Smtp-Source: APXvYqxbpvPs5TgUr+Q0mSTuZHR1aEBQl/5WTqHcjCeyJIB6nEc/oieh4oCPt7wPn8gUuR/CsmhWkJyL2HFvi7Q1gaM=
X-Received: by 2002:a9d:6d15:: with SMTP id o21mr9579177otp.363.1567635103426;
 Wed, 04 Sep 2019 15:11:43 -0700 (PDT)
MIME-Version: 1.0
References: <20190904065320.6005-1-aneesh.kumar@linux.ibm.com>
In-Reply-To: <20190904065320.6005-1-aneesh.kumar@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 4 Sep 2019 15:11:31 -0700
Message-ID: <CAPcyv4hD8SAFNNAWBP9q55wdPf-HYTEjpS4m+rT0VPoGodZULw@mail.gmail.com>
Subject: Re: [PATCH v8] libnvdimm/dax: Pick the right alignment default when
 creating dax devices
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: "Kirill A . Shutemov" <kirill@shutemov.name>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 3, 2019 at 11:53 PM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
>
> Allow arch to provide the supported alignments and use hugepage alignment only
> if we support hugepage. Right now we depend on compile time configs whereas this
> patch switch this to runtime discovery.
>
> Architectures like ppc64 can have THP enabled in code, but then can have
> hugepage size disabled by the hypervisor. This allows us to create dax devices
> with PAGE_SIZE alignment in this case.
>
> Existing dax namespace with alignment larger than PAGE_SIZE will fail to
> initialize in this specific case. We still allow fsdax namespace initialization.
>
> With respect to identifying whether to enable hugepage fault for a dax device,
> if THP is enabled during compile, we default to taking hugepage fault and in dax
> fault handler if we find the fault size > alignment we retry with PAGE_SIZE
> fault size.
>
> This also addresses the below failure scenario on ppc64
>
> ndctl create-namespace --mode=devdax  | grep align
>  "align":16777216,
>  "align":16777216
>
> cat /sys/devices/ndbus0/region0/dax0.0/supported_alignments
>  65536 16777216
>
> daxio.static-debug  -z -o /dev/dax0.0
>   Bus error (core dumped)
>
>   $ dmesg | tail
>    lpar: Failed hash pte insert with error -4
>    hash-mmu: mm: Hashing failure ! EA=0x7fff17000000 access=0x8000000000000006 current=daxio
>    hash-mmu:     trap=0x300 vsid=0x22cb7a3 ssize=1 base psize=2 psize 10 pte=0xc000000501002b86
>    daxio[3860]: bus error (7) at 7fff17000000 nip 7fff973c007c lr 7fff973bff34 code 2 in libpmem.so.1.0.0[7fff973b0000+20000]
>    daxio[3860]: code: 792945e4 7d494b78 e95f0098 7d494b78 f93f00a0 4800012c e93f0088 f93f0120
>    daxio[3860]: code: e93f00a0 f93f0128 e93f0120 e95f0128 <f9490000> e93f0088 39290008 f93f0110
>
> The failure was due to guest kernel using wrong page size.
>
> The namespaces created with 16M alignment will appear as below on a config with
> 16M page size disabled.
>
> $ ndctl list -Ni
> [
>   {
>     "dev":"namespace0.1",
>     "mode":"fsdax",
>     "map":"dev",
>     "size":5351931904,
>     "uuid":"fc6e9667-461a-4718-82b4-69b24570bddb",
>     "align":16777216,
>     "blockdev":"pmem0.1",
>     "supported_alignments":[
>       65536
>     ]
>   },
>   {
>     "dev":"namespace0.0",
>     "mode":"fsdax",    <==== devdax 16M alignment marked disabled.
>     "map":"mem",
>     "size":5368709120,
>     "uuid":"a4bdf81a-f2ee-4bc6-91db-7b87eddd0484",
>     "state":"disabled"
>   }
> ]
>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
>  drivers/nvdimm/nd.h       |  6 ----
>  drivers/nvdimm/pfn_devs.c | 69 +++++++++++++++++++++++++++++----------
>  include/linux/huge_mm.h   |  8 ++++-
>  3 files changed, 59 insertions(+), 24 deletions(-)
>
> diff --git a/drivers/nvdimm/nd.h b/drivers/nvdimm/nd.h
> index e89af4b2d8e9..401a78b02116 100644
> --- a/drivers/nvdimm/nd.h
> +++ b/drivers/nvdimm/nd.h
> @@ -289,12 +289,6 @@ static inline struct device *nd_btt_create(struct nd_region *nd_region)
>  struct nd_pfn *to_nd_pfn(struct device *dev);
>  #if IS_ENABLED(CONFIG_NVDIMM_PFN)
>
> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -#define PFN_DEFAULT_ALIGNMENT HPAGE_PMD_SIZE
> -#else
> -#define PFN_DEFAULT_ALIGNMENT PAGE_SIZE
> -#endif
> -
>  int nd_pfn_probe(struct device *dev, struct nd_namespace_common *ndns);
>  bool is_nd_pfn(struct device *dev);
>  struct device *nd_pfn_create(struct nd_region *nd_region);
> diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
> index ce9ef18282dd..4cb240b3d5b0 100644
> --- a/drivers/nvdimm/pfn_devs.c
> +++ b/drivers/nvdimm/pfn_devs.c
> @@ -103,27 +103,36 @@ static ssize_t align_show(struct device *dev,
>         return sprintf(buf, "%ld\n", nd_pfn->align);
>  }
>
> -static const unsigned long *nd_pfn_supported_alignments(void)
> +const unsigned long *nd_pfn_defining a supported_alignments(void)

Keep this 'static' there's no usage of this routine outside of pfn_devs.c

>  {
> -       /*
> -        * This needs to be a non-static variable because the *_SIZE
> -        * macros aren't always constants.
> -        */
> -       const unsigned long supported_alignments[] = {
> -               PAGE_SIZE,
> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -               HPAGE_PMD_SIZE,
> +       static unsigned long supported_alignments[3];

Why is marked static? It's being dynamically populated each invocation
so static is just wasting space in the .data section.

> +
> +       supported_alignments[0] = PAGE_SIZE;
> +
> +       if (has_transparent_hugepage()) {
> +
> +               supported_alignments[1] = HPAGE_PMD_SIZE;
> +
>  #ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
> -               HPAGE_PUD_SIZE,
> -#endif
> +               supported_alignments[2] = HPAGE_PUD_SIZE;
>  #endif

This ifdef could be hidden in by:

if IS_ENABLED(CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD)

...or otherwise moving this to header file with something like
NVDIMM_PUD_SIZE that is optionally 0 or HPAGE_PUD_SIZE depending on
the config.

> -               0,
> -       };
> -       static unsigned long data[ARRAY_SIZE(supported_alignments)];
> +       } else {
> +               supported_alignments[1] = 0;
> +               supported_alignments[2] = 0;
> +       }
>
> -       memcpy(data, supported_alignments, sizeof(data));
> +       return supported_alignments;
> +}
> +
> +/*
> + * Use pmd mapping if supported as default alignment
> + */
> +unsigned long nd_pfn_default_alignment(void)
> +{
>
> -       return data;
> +       if (has_transparent_hugepage())
> +               return HPAGE_PMD_SIZE;
> +       return PAGE_SIZE;
>  }
>
>  static ssize_t align_store(struct device *dev,
> @@ -302,7 +311,7 @@ struct device *nd_pfn_devinit(struct nd_pfn *nd_pfn,
>                 return NULL;
>
>         nd_pfn->mode = PFN_MODE_NONE;
> -       nd_pfn->align = PFN_DEFAULT_ALIGNMENT;
> +       nd_pfn->align = nd_pfn_default_alignment();
>         dev = &nd_pfn->dev;
>         device_initialize(&nd_pfn->dev);
>         if (ndns && !__nd_attach_ndns(&nd_pfn->dev, ndns, &nd_pfn->ndns)) {
> @@ -412,6 +421,20 @@ static int nd_pfn_clear_memmap_errors(struct nd_pfn *nd_pfn)
>         return 0;
>  }
>
> +static bool nd_supported_alignment(unsigned long align)
> +{
> +       int i;
> +       const unsigned long *supported = nd_pfn_supported_alignments();
> +
> +       if (align == 0)
> +               return false;
> +
> +       for (i = 0; supported[i]; i++)
> +               if (align == supported[i])
> +                       return true;
> +       return false;
> +}
> +
>  /**
>   * nd_pfn_validate - read and validate info-block
>   * @nd_pfn: fsdax namespace runtime state / properties
> @@ -496,6 +519,18 @@ int nd_pfn_validate(struct nd_pfn *nd_pfn, const char *sig)
>                 return -EOPNOTSUPP;
>         }
>
> +       /*
> +        * Check whether the we support the alignment. For Dax if the
> +        * superblock alignment is not matching, we won't initialize
> +        * the device.
> +        */
> +       if (!nd_supported_alignment(align) &&
> +                       !memcmp(pfn_sb->signature, DAX_SIG, PFN_SIG_LEN)) {
> +               dev_err(&nd_pfn->dev, "init failed, alignment mismatch: "
> +                               "%ld:%ld\n", nd_pfn->align, align);
> +               return -EOPNOTSUPP;
> +       }
> +
>         if (!nd_pfn->uuid) {
>                 /*
>                  * When probing a namepace via nd_pfn_probe() the uuid
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 45ede62aa85b..36708c43ef8e 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -108,7 +108,13 @@ static inline bool __transparent_hugepage_enabled(struct vm_area_struct *vma)
>
>         if (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_FLAG))
>                 return true;
> -
> +       /*
> +        * For dax let's try to do hugepage fault always. If the kernel doesn't
> +        * support hugepages, namespaces with hugepage alignment will not be
> +        * enabled. For namespace with PAGE_SIZE alignment, we try to handle
> +        * hugepage fault but will fallback to PAGE_SIZE via the check in
> +        * __dev_dax_pmd_fault

Ok, this is better, but I think it can be clarified further.

"For dax vmas, try to always use hugepage mappings. If the kernel does
not support hugepages, fsdax mappings will fallback to PAGE_SIZE
mappings, and device-dax namespaces, that try to guarantee a given
mapping size, will fail to enable."

The last sentence about PAGE_SIZE namespaces is not relevant to
__transparent_hugepage_enabled(), it's an internal implementation
detail of the device-dax driver.

