Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBFF2C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 08:15:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66BA0217FA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 08:15:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oQtHvnEb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66BA0217FA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 171C66B0005; Thu, 25 Apr 2019 04:15:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11F406B0006; Thu, 25 Apr 2019 04:15:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 017796B0007; Thu, 25 Apr 2019 04:15:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id A2A1E6B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 04:15:23 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id h4so20246416wrw.5
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 01:15:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=658SRk7b8ZveF4hHRQ6cfQbo38vY/JLKn59mggf35X8=;
        b=cy/LgEKq/PtnOgITDkE2t4Ujd+eWxHeO4OgptYtLUhDGUqKaZkGFj61HSZ3sTpAL8f
         kOgR3+W/cj6NkBP44N8SQbgI2/rS3ysgQATqoQ4owC+Xcjx0AkY34Mpxz3P+gR+2rPzj
         gUonvS4N7vqrjI+2OYGcE6GkSnJSwEpcV2GTPHsIqt4GKrCkKnTj/CAXmj7gHqUDeSY+
         0xUoRvGLDyvxORiFLUGz+ETLM4KjSg0eCivZYJG0r2XIakAPr5uJK9qAO/H3P5L/22vv
         cPzd4PzctVXzCcCxTla5xFpDykmD8UtsGi/rmWvEhjMp4Pcs27XBrQsUYR5hECGpyroN
         JJSw==
X-Gm-Message-State: APjAAAU8hc4Vt7x49Gn5UU/l2Ff/LFwVyZRT46fUXTDjYQc3FWQec7V2
	yToKZ0LyCzZ61kaKME2uWVsjX+EsbxvbIp2x7ILNnc55Rr9Neb4T5nKCkB9o5CRpMEy+wm2FU8n
	Eru9Nh4tA53pt6jslBZTNKbQfelRoT48hQceh0WbhdfjsVQR/hZoYUuHRWsEfXvdOQw==
X-Received: by 2002:adf:b458:: with SMTP id v24mr26167620wrd.46.1556180123184;
        Thu, 25 Apr 2019 01:15:23 -0700 (PDT)
X-Received: by 2002:adf:b458:: with SMTP id v24mr26167548wrd.46.1556180122260;
        Thu, 25 Apr 2019 01:15:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556180122; cv=none;
        d=google.com; s=arc-20160816;
        b=iJ2oIzZaKRSBdFEmqvYRasrwp4Hj9uAkq21QlLv+sR5BtYapemHp6CqlRYfPtWoL2+
         yyir2iND7YslP0nGHTxae7ar2+ex+y5q5DYyyJpuTEJQ8GidJBfUcVS+WHRcWA64yoay
         czJpCx9lCmBz+e1vOgeBhjmLFoJr4zvD2fyW06TSnuvdW06D9zCZOxwBSTdpA4iV6G7I
         c2x6HzoDCS72mg+Lgdmy2gGI963mPRqxxfExRWvCyhf8Qr+Hfdoklen8i4MFLwB7IRL/
         UrCThtcTczqC5ZqzR/BXxnABn3ht5ex3zjIaNKFKqIhmEb2aV0cEdRINx52TgnW9amcR
         fNcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=658SRk7b8ZveF4hHRQ6cfQbo38vY/JLKn59mggf35X8=;
        b=wcXLS2yZvLiPSaAlvu7qyQysfU0Zt7uZ5SyMi7zfq+wBFV3qvCPzuNmdDuakrLpzcP
         PhhWdbvWRyKg1ysORZrdX3oNi9N1o7JX0+wAKWtq83f/83jFZKn4vBo0J7XDPVUWc3Zg
         mZ77hzaFj0lQSbPaq8XlmfJaYsjE25DqpSpwITpf+Yd2aeyrU3Obwhok7Csot9hp5drn
         SbMfD8QftEdvcAoEr1G79Ip21yLeSRUDyZI3eqkPbcEccotXakS+3qi70yixgMwUtbd4
         lYAuTarQ2MnGo3IvrhnwvUUB0OanEyK02tfBHJ3XXXLq0/Hybiyz79gBUbLWjGvgJSLO
         4ZSw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oQtHvnEb;
       spf=pass (google.com: domain of tom.leiming@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=tom.leiming@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v7sor11850697wro.43.2019.04.25.01.15.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 01:15:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of tom.leiming@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oQtHvnEb;
       spf=pass (google.com: domain of tom.leiming@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=tom.leiming@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=658SRk7b8ZveF4hHRQ6cfQbo38vY/JLKn59mggf35X8=;
        b=oQtHvnEbDeSrlObkmdqj7I89uy+PKxhm7l8uwYp+Enzh10hwieUj5ovRluveiHzGHX
         fj856YFHPgZ1evvdd8PxRLmoqJJ4onCSHrue5hdyaTqYvvsnopodh0WHRaFKIwoOOeUy
         AG3fWsEoI4jqmsSHcKN5o7JootWyKhEEmX3Xca+nP6HARwEAqsg8pgYXgkItyVeqG5IK
         hDtTrnFT3rpyuGMlyDwku568xjZ257nQIKoC8+JgKcv/mUSW0GOv2ZHCAieTVl4lGoqf
         sRTcKO8KvtlctLQQPC+2Bxspq8rMBltfjDP3JZiZ1kts70G/Wch2yUCdfgezj1Mn/iy9
         F8MQ==
X-Google-Smtp-Source: APXvYqwiJgU/SHYbS0sbX0x3sq1gOWOxflVYPcrLBtsm9COY3bRkWxYcnpdG5htb/Md8/R7C52iBdCLVqEyRI4x1+nE=
X-Received: by 2002:adf:b60a:: with SMTP id f10mr23819235wre.116.1556180121881;
 Thu, 25 Apr 2019 01:15:21 -0700 (PDT)
MIME-Version: 1.0
References: <38bef24c-3839-11b0-a192-6cf511d8b268@lca.pw>
In-Reply-To: <38bef24c-3839-11b0-a192-6cf511d8b268@lca.pw>
From: Ming Lei <tom.leiming@gmail.com>
Date: Thu, 25 Apr 2019 16:15:10 +0800
Message-ID: <CACVXFVO_9KOkC=A-uz-NjUOxs_r771yibnKaCPs0z1VuK=QRtw@mail.gmail.com>
Subject: Re: bio_iov_iter_get_pages() + page_alloc.shuffle=1 migrating failures
To: Qian Cai <cai@lca.pw>
Cc: Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@lst.de>, 
	linux-block <linux-block@vger.kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 4:13 PM Qian Cai <cai@lca.pw> wrote:
>
> Memory offline [1] starts to fail on linux-next on ppc64le with
> page_alloc.shuffle=1 where the "echo offline" command hangs with lots of
> migrating failures below. It seems in migrate_page_move_mapping()
>
>         if (!mapping) {
>                 /* Anonymous page without mapping */
>                 if (page_count(page) != expected_count)
>                         return -EAGAIN;
>
> It expected count=1 but actual count=2.
>
> There are two ways to make the problem go away. One is to remove this line in
> __shuffle_free_memory(),
>
>         shuffle_zone(z);
>
> The other is reverting some bio commits. Bisecting so far indicates the culprit
> is in one of those (the 3rd commit looks more suspicious than the others).
>
> block: only allow contiguous page structs in a bio_vec
> block: don't allow multiple bio_iov_iter_get_pages calls per bio
> block: change how we get page references in bio_iov_iter_get_pages
>
> [  446.578064] migrating pfn 2003d5eaa failed ret:22
> [  446.578066] page:c00a00800f57aa80 count:2 mapcount:0 mapping:c000001db4c827e9
> index:0x13c08a
> [  446.578220] anon
> [  446.578222] flags: 0x83fffc00008002e(referenced|uptodate|dirty|active|swapbacked)
> [  446.578347] raw: 083fffc00008002e c00a00800f57f808 c00a00800f579f88
> c000001db4c827e9
> [  446.944807] raw: 000000000013c08a 0000000000000000 00000002ffffffff
> c00020141a738008
> [  446.944883] page dumped because: migration failure
> [  446.944948] page->mem_cgroup:c00020141a738008
> [  446.945024] page allocated via order 0, migratetype Movable, gfp_mask
> 0x100cca(GFP_HIGHUSER_MOVABLE)
> [  446.945148]  prep_new_page+0x390/0x3a0
> [  446.945228]  get_page_from_freelist+0xd9c/0x1bf0
> [  446.945292]  __alloc_pages_nodemask+0x1cc/0x1780
> [  446.945335]  alloc_pages_vma+0xc0/0x360
> [  446.945401]  do_anonymous_page+0x244/0xb20
> [  446.945472]  __handle_mm_fault+0xcf8/0xfb0
> [  446.945532]  handle_mm_fault+0x1c0/0x2b0
> [  446.945615]  __get_user_pages+0x3ec/0x690
> [  446.945652]  get_user_pages_unlocked+0x104/0x2f0
> [  446.945693]  get_user_pages_fast+0xb0/0x200
> [  446.945762]  iov_iter_get_pages+0xf4/0x6a0
> [  446.945802]  bio_iov_iter_get_pages+0xc0/0x450
> [  446.945876]  blkdev_direct_IO+0x2e0/0x630
> [  446.945941]  generic_file_read_iter+0xbc/0x230
> [  446.945990]  blkdev_read_iter+0x50/0x80
> [  446.946031]  aio_read+0x128/0x1d0
> [  446.946082] migrating pfn 2003d5fe0 failed ret:22
> [  446.946084] page:c00a00800f57f800 count:2 mapcount:0 mapping:c000001db4c827e9
> index:0x13c19e
> [  446.946239] anon
> [  446.946241] flags: 0x83fffc00008002e(referenced|uptodate|dirty|active|swapbacked)
> [  446.946384] raw: 083fffc00008002e c000200deb3dfa28 c00a00800f57aa88
> c000001db4c827e9
> [  446.946497] raw: 000000000013c19e 0000000000000000 00000002ffffffff
> c00020141a738008
> [  446.946605] page dumped because: migration failure
> [  446.946662] page->mem_cgroup:c00020141a738008
> [  446.946724] page allocated via order 0, migratetype Movable, gfp_mask
> 0x100cca(GFP_HIGHUSER_MOVABLE)
> [  446.946846]  prep_new_page+0x390/0x3a0
> [  446.946899]  get_page_from_freelist+0xd9c/0x1bf0
> [  446.946959]  __alloc_pages_nodemask+0x1cc/0x1780
> [  446.947047]  alloc_pages_vma+0xc0/0x360
> [  446.947101]  do_anonymous_page+0x244/0xb20
> [  446.947143]  __handle_mm_fault+0xcf8/0xfb0
> [  446.947200]  handle_mm_fault+0x1c0/0x2b0
> [  446.947256]  __get_user_pages+0x3ec/0x690
> [  446.947306]  get_user_pages_unlocked+0x104/0x2f0
> [  446.947366]  get_user_pages_fast+0xb0/0x200
> [  446.947458]  iov_iter_get_pages+0xf4/0x6a0
> [  446.947515]  bio_iov_iter_get_pages+0xc0/0x450
> [  446.947588]  blkdev_direct_IO+0x2e0/0x630
> [  446.947636]  generic_file_read_iter+0xbc/0x230
> [  446.947703]  blkdev_read_iter+0x50/0x80
> [  446.947758]  aio_read+0x128/0x1d0
>
> [1]
> i=0
> found=0
> for mem in $(ls -d /sys/devices/system/memory/memory*); do
>         i=$((i + 1))
>         echo "iteration: $i"
>         echo offline > $mem/state
>         if [ $? -eq 0 ] && [ $found -eq 0 ]; then
>                 found=1
>                 continue
>         fi
>         echo online > $mem/state
> done

Please try the following patch:

https://git.kernel.org/pub/scm/linux/kernel/git/axboe/linux-block.git/commit/?h=for-5.2/block&id=0257c0ed5ea3de3e32cb322852c4c40bc09d1b97

Thanks,
Ming Lei

