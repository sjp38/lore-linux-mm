Return-Path: <SRS0=IlG+=PR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FE6FC43387
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 16:16:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 290482070B
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 16:16:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="o0tKtF4y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 290482070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE4EA8E009E; Wed,  9 Jan 2019 11:16:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6BD38E0038; Wed,  9 Jan 2019 11:16:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A84248E009E; Wed,  9 Jan 2019 11:16:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3624D8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 11:16:55 -0500 (EST)
Received: by mail-lf1-f69.google.com with SMTP id g16so609587lfb.22
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 08:16:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=guTeVeqW9KLhp8/c6KawSHCWPSc4BbHsuX5EpTBXe4Q=;
        b=BHvomHifCn9y4aDcRGJBddMfb+xY0oGohrU6E4gCT0PAvN4gIa+K3uwPN1GSKFMhBH
         HPmRAEf9k8/ZB6C/Eh2dGCZbTy8oIexdk/Z/DdR11HvFsSwm4lLHxK09aDoGJT+E4BPv
         Vv3hTFbxO0Sk9cEYiZZlXJD4ZUZ4CAD7RDNEIw7u8zc5iRwrwUZMObR+MbzNDq1T/811
         Xf4+2OCikGU8KyrrAeLnTUXAbFqUBaxp2JX7rS1/BCa7LBdem+oEEgamgtd9NFzva2/o
         V4rAfRGl9zjj9GD5u7nLqXFhotWm4NPytIVAopkxWakF+O2b6H4wd4dCNlR7UUJfRxr4
         4xEA==
X-Gm-Message-State: AJcUukcQIwIt/T6kmhLd/NYRwMeOKNqCi0iOBBg4WySFUMLzCJh40Zzc
	exTTjKCP9XTAkd+cHpzlogmbBWvSvhLczK5CzWRN1t0XzYUU5W/1AQ3N9CQ9CMnYalfEExx88vU
	3cynV/MiKXrvOd8Wai85UaqGy7C9xvq3qKM9+Cso4ten5qfNhHBx5W1NWFp7cnipg4pF7CYjCzR
	XGheTFUGWIyuZUoFGCeJsBlhiq+QVYTCsRRP6OPzUL50Lxgk6Z1C54/pClLntnx9RytCe9muyCt
	fD9GAv4J8+v2Eqvg047vBgOEaIbqwvT8oM5H0SUXyKmMQjIJq3AfvBbU+5GbN1PaD1xNWWVv02O
	PIRJ3TFuNzSG4YwycAJ5v50ati8b6Y75IVAcdQeqVV774glFyvGDQ/JMOI7veDr2BBU/J8Uu1cu
	7
X-Received: by 2002:a2e:91d1:: with SMTP id u17-v6mr3819058ljg.160.1547050614542;
        Wed, 09 Jan 2019 08:16:54 -0800 (PST)
X-Received: by 2002:a2e:91d1:: with SMTP id u17-v6mr3819012ljg.160.1547050613520;
        Wed, 09 Jan 2019 08:16:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547050613; cv=none;
        d=google.com; s=arc-20160816;
        b=tsInwoNh7tJ7UkWAe2tyHB0HRJ1cETNd3RvyeKecM4J/ixGOclh+bn4cyAsDSI22kl
         i9gABmJIN8HgSHp/iyOmavr3UaAw679b+kqDwJFGQcicruFVNEYXAGHc5f1ZRPeMiAcV
         +oBpxSr9WdO/05brVenIszvfuBn9bjtc5hngTrJ+owYd8DNWKtkF8tUTW+ml/+iviVXo
         5r0xBaWE9HBLxy1mfHk8uyrOZuyCuJqb5k77oTUVqCi02Xlo3qIS/yc4Q+86hU5u3oqt
         +78CQCSrbkZ5+GDfW4tcak9BJc1cihRUXWq3ipDvX0crXkmBb8tWWsi2F6+u7lb3MOTK
         drZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=guTeVeqW9KLhp8/c6KawSHCWPSc4BbHsuX5EpTBXe4Q=;
        b=laQcdWRvON2v6xlfQXP+0XK8MnyKeaYxebh6ZjXjqq86YYMhmdxMYuLlps8t55qYuv
         UEmEsCkWZLZNegU0be3hyFhkRFpe8OafyDteAbmHm/3a1X0eR/oxAM1nxFL6UksQKUdn
         SE4T614jAw9m8GpSWPZR506ZHFl9GPoG/eptRA6sZAOoWrEmHziq1PMh3q4jkYrucFMu
         T6HbtuvtNKy1kvo3VrM+a+aoobjpsE5yeYQdIcafXuGD0ihDvyMasVSyGMBaIfZi9bdE
         Gf//+jwZnjRflVTt5Ecr1YdXFbkCb7joUlz+Rgo1WbKK3RgaLutW9ISiWGNpW4VLVd9x
         hieQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=o0tKtF4y;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s22sor17248274lfb.46.2019.01.09.08.16.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 Jan 2019 08:16:53 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=o0tKtF4y;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=guTeVeqW9KLhp8/c6KawSHCWPSc4BbHsuX5EpTBXe4Q=;
        b=o0tKtF4yQrmQxwfrlRXVheuHHZtBgHvb3NozqG4C0b4owVYXoP8CXsWB2hn1LzrbkL
         Cu78l0TfbmiJIHHA7NBpRZBy2GQPHVZ68EMv4zAUnSPxButnaO3gbLgK6rpQA5yUkGjJ
         Zb9M8nyYhYDADOePrU+MGnv2oEn1qcrqEjAsIBE3nNidMD4gU04E8KiajvoCa2A6RuhC
         gWIigZ643mRaEHMsDAJXyYr/Ob9ivq0WzF8k9QmvCc4hFhcLVvxBHnJfVeNRlx6egG1/
         ERrMa4A8XcxoS41mrfdKlhatMtB1TzVzxJugo9rp4lgVxNK46DvXdv8cMC+7A+V4BMJc
         VkBw==
X-Google-Smtp-Source: ALg8bN6L/1v9lG/onJDkftwo5CLjSVh6yjnoXg6BMYTz1TsHsWSZwZtjHWHD4JJDm4oN2uTJ0xf5zCWDrGqYkoopjAs=
X-Received: by 2002:a19:c70a:: with SMTP id x10mr3764528lff.88.1547050612929;
 Wed, 09 Jan 2019 08:16:52 -0800 (PST)
MIME-Version: 1.0
References: <20190109161916.GA23410@jordon-HP-15-Notebook-PC>
In-Reply-To: <20190109161916.GA23410@jordon-HP-15-Notebook-PC>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Wed, 9 Jan 2019 21:50:44 +0530
Message-ID:
 <CAFqt6zbeHPs359c03q8wCENfW5DJ3W6_ber78fCmoQzYcUhpCQ@mail.gmail.com>
Subject: Re: [PATCH] include/linux/hmm.h: Convert to use vm_fault_t
To: Andrew Morton <akpm@linux-foundation.org>
Cc: jglisse@redhat.com, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, 
	Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190109162044.3eO38wjH9s0Sh17klxF0fb10WHzh3PE_fuAtpNzeK4Y@z>

On Wed, Jan 9, 2019 at 9:45 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> convert to use vm_fault_t type as return type for
> fault handler.
>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>

kbuild reported a warning during testing of final vm_fault_t patch integrated
in mm tree.

[auto build test WARNING on linus/master]
[also build test WARNING on v5.0-rc1 next-20190109]
[if your patch is applied to the wrong git tree, please drop us a note
to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Souptick-Joarder/mm-Create-the-new-vm_fault_t-type/20190109-154216

>> kernel/memremap.c:46:34: warning: incorrect type in return expression (different base types)
   kernel/memremap.c:46:34:    expected restricted vm_fault_t
   kernel/memremap.c:46:34:    got int

This patch has fixed the warning.

> ---
>  include/linux/hmm.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 66f9ebb..7c5ace3 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -468,7 +468,7 @@ struct hmm_devmem_ops {
>          * Note that mmap semaphore is held in read mode at least when this
>          * callback occurs, hence the vma is valid upon callback entry.
>          */
> -       int (*fault)(struct hmm_devmem *devmem,
> +       vm_fault_t (*fault)(struct hmm_devmem *devmem,
>                      struct vm_area_struct *vma,
>                      unsigned long addr,
>                      const struct page *page,
> --
> 1.9.1
>

