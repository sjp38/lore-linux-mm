Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C6E3C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 22:24:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B97C2075B
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 22:24:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="x0gRCKA2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B97C2075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9AD076B0003; Mon, 12 Aug 2019 18:24:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95DD56B0005; Mon, 12 Aug 2019 18:24:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 824686B0006; Mon, 12 Aug 2019 18:24:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0061.hostedemail.com [216.40.44.61])
	by kanga.kvack.org (Postfix) with ESMTP id 5BE6D6B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 18:24:23 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id BDDED3D15
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 22:24:22 +0000 (UTC)
X-FDA: 75815205564.27.roof19_605c67574404a
X-HE-Tag: roof19_605c67574404a
X-Filterd-Recvd-Size: 5725
Received: from mail-ot1-f68.google.com (mail-ot1-f68.google.com [209.85.210.68])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 22:24:22 +0000 (UTC)
Received: by mail-ot1-f68.google.com with SMTP id q20so12183472otl.0
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 15:24:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=FD1szyxYIZRFxBXLh6OsEaGEchmLGdiUNjpQeITxC5M=;
        b=x0gRCKA2MXc6jwpdoG/TD2IO5bNpn+KvoJBHqbuTFvYsphI9ZOW3AsLFTvGTGaBcYf
         RXeEQjAS7obV+BaMTdZMP8wgP9cCdfivoRhOSSJlo1Z5CZcFaW9WRf5Nbz2vuEwz9BHO
         CTPVnpm6p1Svao0hA1gPSbLM8aO2CgSELXaqp4B3NEVb2TYyFBGnZyWvtKuElCmEg9Y9
         2684+SERAdl0y8BhILj5oAWGrfdVI2IqGuBac1Xq6S8MrelSVVIf8h5B+ZX8xtZ+Y4j8
         0cIiaBzKvNv833gjthAES+x42kYGE7WEjgb+I7K5IyHz3cyOXJYFYRXUt4EGdLKdJPuu
         QMeA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=FD1szyxYIZRFxBXLh6OsEaGEchmLGdiUNjpQeITxC5M=;
        b=rW5mQ7JxbnEtV9sMwjg0IDpA7lK/8sDLbU+gtbvkA/Gs0vHxJQ+cp25Hc7il58h8q9
         bkyP8HCtumTnbKnRS0K7zEa3Zk5V/zV44ubULf92CsCrEOq7w7UpNQMl9Ym7km2p1EYv
         ENbr2UvLvSFX2Rx+U+QaGMTRRmK0O0z5iz7sudMLmgrndyVvkIXT5jW9ccBM4/E9THq+
         CL0P8TgkYRoq4x9v5JEo129MGze5LhKxa9kH1JFHalSj5qWI7b0dOTiljgcjEVUCJDWy
         SpvRyliv74KuxZfohYQErEA9+JBLhaUo2uNxahJI3rqiy6o0tT66N6B0lDhnSXN/sB9J
         BZ6w==
X-Gm-Message-State: APjAAAXXZ6yIjoAqJlKoo3e1QyKprBPb9yrI4m4ftzOLU3L3gC6mLzpP
	JraeuKbOtCmKktSmBosaYe22q2iZ2PdfsQgQ55yzVw==
X-Google-Smtp-Source: APXvYqyTjBOGgU/+dTdLpyuKWrW67Z3rfVh/4MI7eXiUUJ6wgK016/SnhTUKO42pQZXtyuBZxQKUvdSL/kBmh0RvuUc=
X-Received: by 2002:aca:be43:: with SMTP id o64mr912541oif.149.1565648660956;
 Mon, 12 Aug 2019 15:24:20 -0700 (PDT)
MIME-Version: 1.0
References: <20190812213158.22097.30576.stgit@localhost.localdomain> <20190812213324.22097.30886.stgit@localhost.localdomain>
In-Reply-To: <20190812213324.22097.30886.stgit@localhost.localdomain>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 12 Aug 2019 15:24:09 -0700
Message-ID: <CAPcyv4jEvPL3qQffDsJxKxkCJLo19FN=gd4+LtZ1FnARCr5wBw@mail.gmail.com>
Subject: Re: [PATCH v5 1/6] mm: Adjust shuffle code to allow for future coalescing
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: nitesh@redhat.com, KVM list <kvm@vger.kernel.org>, 
	"Michael S. Tsirkin" <mst@redhat.com>, David Hildenbrand <david@redhat.com>, Dave Hansen <dave.hansen@intel.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Andrew Morton <akpm@linux-foundation.org>, virtio-dev@lists.oasis-open.org, 
	Oscar Salvador <osalvador@suse.de>, yang.zhang.wz@gmail.com, 
	Pankaj Gupta <pagupta@redhat.com>, Rik van Riel <riel@surriel.com>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, lcapitulino@redhat.com, 
	"Wang, Wei W" <wei.w.wang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, 
	Paolo Bonzini <pbonzini@redhat.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 12, 2019 at 2:33 PM Alexander Duyck
<alexander.duyck@gmail.com> wrote:
>
> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>
> This patch is meant to move the head/tail adding logic out of the shuffle

s/This patch is meant to move/Move/

> code and into the __free_one_page function since ultimately that is where
> it is really needed anyway. By doing this we should be able to reduce the
> overhead

Is the overhead benefit observable? I would expect the overhead of
get_random_u64() dominates.

> and can consolidate all of the list addition bits in one spot.

This sounds the better argument.

[..]
> diff --git a/mm/shuffle.h b/mm/shuffle.h
> index 777a257a0d2f..add763cc0995 100644
> --- a/mm/shuffle.h
> +++ b/mm/shuffle.h
> @@ -3,6 +3,7 @@
>  #ifndef _MM_SHUFFLE_H
>  #define _MM_SHUFFLE_H
>  #include <linux/jump_label.h>
> +#include <linux/random.h>
>
>  /*
>   * SHUFFLE_ENABLE is called from the command line enabling path, or by
> @@ -43,6 +44,32 @@ static inline bool is_shuffle_order(int order)
>                 return false;
>         return order >= SHUFFLE_ORDER;
>  }
> +
> +static inline bool shuffle_add_to_tail(void)
> +{
> +       static u64 rand;
> +       static u8 rand_bits;
> +       u64 rand_old;
> +
> +       /*
> +        * The lack of locking is deliberate. If 2 threads race to
> +        * update the rand state it just adds to the entropy.
> +        */
> +       if (rand_bits-- == 0) {
> +               rand_bits = 64;
> +               rand = get_random_u64();
> +       }
> +
> +       /*
> +        * Test highest order bit while shifting our random value. This
> +        * should result in us testing for the carry flag following the
> +        * shift.
> +        */
> +       rand_old = rand;
> +       rand <<= 1;
> +
> +       return rand < rand_old;
> +}

This function seems too involved to be a static inline and I believe
each compilation unit that might call this routine gets it's own copy
of 'rand' and 'rand_bits' when the original expectation is that they
are global. How about leave this bit to mm/shuffle.c and rename it
coin_flip(), or something more generic, since it does not
'add_to_tail'? The 'add_to_tail' action is something the caller
decides.

