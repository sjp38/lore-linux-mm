Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1690FC04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 23:40:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA4EF2084E
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 23:40:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kO9iPKcd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA4EF2084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 032E46B0005; Tue, 14 May 2019 19:40:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F24C46B0006; Tue, 14 May 2019 19:40:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E13276B0007; Tue, 14 May 2019 19:40:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id BE0036B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 19:40:24 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id i124so794039qkf.14
        for <linux-mm@kvack.org>; Tue, 14 May 2019 16:40:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=mqlrXy5kwdDrwo0UFJq8GGPqMotywoeM6XVl2pYk4JQ=;
        b=TJ1ICHaXQFXvO+R4SWz89OtB0O1KPjemvduvWRXOdBf9fF0vRcJ6eU3fQScGlqaUbr
         zXG/8SpaMbe+tKg4md4dbbr4/YGamH6F6hfIVKi5t+9CWagqN8Uhfln36iqugzMRGP1T
         X5cPqbdJ6mgy8oq2rMYs6Vn7HLS9CUktA7aVePo6n/wM1pnTy0eRvO6TOybq0mQ3h076
         Kcxsym8mUX7I9HhINz6Gnk8Nlghyc5lbcAdw4//FBeanwxgFok11PuXKMzuhEM7mY3Pk
         YB5tHSPBlKMzgWOW81M2k7Q1kT46zsFwEFEGk7BtOFrx10kiOi2AK1pycAFaHN+31Jg2
         +fTA==
X-Gm-Message-State: APjAAAUsLlootofdsaMthdE3b16NfqhtdL1VbuqRgRr9W7SyCDpfLsZ0
	DMcldoAOmpsjvIUncynacDhajUh4FHWp/DN5aVvQUkVz36S1VGpw3dczyDD68wFwrGmjv5/TJ+v
	X5X8/xqjpEtb/vrNn+S2S2G9sPlxhuKh+ecoifUkIpt33pDe4TnBFurPWMutV0gT4cw==
X-Received: by 2002:ac8:3f75:: with SMTP id w50mr33589406qtk.27.1557877224495;
        Tue, 14 May 2019 16:40:24 -0700 (PDT)
X-Received: by 2002:ac8:3f75:: with SMTP id w50mr33589351qtk.27.1557877223692;
        Tue, 14 May 2019 16:40:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557877223; cv=none;
        d=google.com; s=arc-20160816;
        b=ptLIXCvt3exYeZICOTjtTxGpY2kOQkOOx1AZo2CTdkMkejsrRaofsiwptdd7wutWl7
         gs7MIPwlQ2dHx2Nf2Fb743WsNsogCuA+ep3vkX9Gjmc9XR2jMyEstrlyuaRd/vDusasX
         D+iZIbQTOloQmhVyJd0o2cJoIExAveNC8e6jCsX6eW8uACVh42LAEpw/mmiRbfKip9K5
         3h4hZ74QuUUtLwNYao2ckqnjE913rSXnF/xTMHr0gzHcyXBRInslf8CT45JUlTEfXKay
         JMKaYyA8lz1x61qWtQtd5GssThWonQsUwsslAVLZfh6o9NhiZnowFdnF0CKjNjt1NDlt
         KBNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=mqlrXy5kwdDrwo0UFJq8GGPqMotywoeM6XVl2pYk4JQ=;
        b=ZNaSWlFzhZ8W7PVcoxhd1OHPJYRWaBVorAlI87SV+nJ/PwftoKEhJpZZyq52q2fN4B
         J9lyrH3skKTYKaTaTD049iga7I4KKGZSzbmt8w1xQoYdAYI+ZCDsl9rJPWn84FkSwcO9
         kWcwpflCWV6iiblY9+PWsBIB8nERbdhqpWfQP8m5BURdpvJYNUsQKZ4/l5Uf9LDKjQ7S
         ZOf3RJHKU9Hq6aEsOwyYxjy8F6Uvqhpj7V5CUGNRmWrw0iYMnoNUOTPlTNwOQYTSWDpD
         7m9oQNKrlYEsxqxeYwg6lQfiBlqQfUEyc09lWr90ibx2mr7eLv2wzpHNdwZUR5/VFjTq
         5G+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kO9iPKcd;
       spf=pass (google.com: domain of liu.song.a23@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liu.song.a23@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r18sor322095qve.40.2019.05.14.16.40.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 16:40:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of liu.song.a23@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kO9iPKcd;
       spf=pass (google.com: domain of liu.song.a23@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liu.song.a23@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=mqlrXy5kwdDrwo0UFJq8GGPqMotywoeM6XVl2pYk4JQ=;
        b=kO9iPKcdYHvq7Sy8SSA7D9MRPKbtN9+us4/EErldh7Q6WJGODf0MesKSC5OhxQ7IN7
         lPxyWzUjq99r96cm2T2CxpIw0l5KV8jnTT5Jg5O4a4n29kjPQQCyfjfxzDkFEw3RrC1C
         Q16I9GbitKoCMSEaV4V6wt7Tt2HupryJBrlm+WwpOv/TYRHgp4VC8IdN0ygNNWTs6JFt
         zDH91eVMgIzDnvEIToaXNoZSbRBcGtPwjJvusEUBxuRhCqb28S75HrSU6QVGvsj4qhOA
         sS3OBF3WfP4GXaT75hzGXjBonIl3CyNpZNaLXN3sNusLlIPjy2g4Poa93CznpOcD5a2Y
         FfSQ==
X-Google-Smtp-Source: APXvYqzwbNTznSBrD6LoX9VLQYRvaPeKLNqZGrq7TRAldxBbjP7SsrUY2Ndu+OYRW/2V+3p4I5kx8+x21B1wcVBFZZo=
X-Received: by 2002:a0c:aed4:: with SMTP id n20mr30980915qvd.195.1557877223375;
 Tue, 14 May 2019 16:40:23 -0700 (PDT)
MIME-Version: 1.0
References: <1556234531-108228-1-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1556234531-108228-1-git-send-email-yang.shi@linux.alibaba.com>
From: Song Liu <liu.song.a23@gmail.com>
Date: Tue, 14 May 2019 16:40:12 -0700
Message-ID: <CAPhsuW5B5twTEk=SZZqZCH9_hjEjJ_KFP_GYq3T6nzv7kRSM0w@mail.gmail.com>
Subject: Re: [PATCH] mm: filemap: correct the comment about VM_FAULT_RETRY
To: Yang Shi <yang.shi@linux.alibaba.com>, jbacik@fb.com
Cc: josef@toxicpanda.com, Andrew Morton <akpm@linux-foundation.org>, 
	Linux-MM <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 4:22 PM Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
> The commit 6b4c9f446981 ("filemap: drop the mmap_sem for all blocking
> operations") changed when mmap_sem is dropped during filemap page fault
> and when returning VM_FAULT_RETRY.
>
> Correct the comment to reflect the change.
>
> Cc: Josef Bacik <josef@toxicpanda.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

Looks good to me!

Acked-by: Song Liu <songliubraving@fb.com>

> ---
>  mm/filemap.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/mm/filemap.c b/mm/filemap.c
> index d78f577..f0d6250 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2545,10 +2545,8 @@ static struct file *do_async_mmap_readahead(struct vm_fault *vmf,
>   *
>   * vma->vm_mm->mmap_sem must be held on entry.
>   *
> - * If our return value has VM_FAULT_RETRY set, it's because
> - * lock_page_or_retry() returned 0.
> - * The mmap_sem has usually been released in this case.
> - * See __lock_page_or_retry() for the exception.
> + * If our return value has VM_FAULT_RETRY set, it's because the mmap_sem
> + * may be dropped before doing I/O or by lock_page_maybe_drop_mmap().
>   *
>   * If our return value does not have VM_FAULT_RETRY set, the mmap_sem
>   * has not been released.
> --
> 1.8.3.1
>

