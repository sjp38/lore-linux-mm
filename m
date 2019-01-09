Return-Path: <SRS0=IlG+=PR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F4C0C43612
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 17:38:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 114FA206B7
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 17:38:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="PCmVpAsT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 114FA206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84A968E009D; Wed,  9 Jan 2019 12:38:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FB228E0038; Wed,  9 Jan 2019 12:38:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E9E78E009D; Wed,  9 Jan 2019 12:38:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 45CE48E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 12:38:06 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id h3so4270503ywc.20
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 09:38:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=00fTbS3NCEslFjaEEkgF4Su3Ks4m2l6BsBiP5Boa2l0=;
        b=MmK1wTqEwJGWuBqjDaqAOygg6xfO+pGmB+BFfs1oFNOlEbw1UYrxJ2gaavbc80WusL
         U5vKs8zGyTJK1bYQyP9hQOLlQewr1Sg70sd3zEVkBVy6AJJ/co9by5davD/JUBs0e2pn
         Mbz1/kOh37RnMbkT6z8oXx6OdDtdNoGBIYZk2+j1+lVouGPeKQQ2mNio2KpS/XbZRG9n
         CSpEKK20ENGleLIlLxeKQay4lv+Dly5/T+2LuNlaEtURiEn5ukLYuu4sbFmyj6BDYRxo
         eeDDoXXdPFXh/IbsAKQt9s5Ht8jygdrA2KKQu8LuYZAlw9DmLIl9Au9SRWvmqVwUyXkN
         6eeg==
X-Gm-Message-State: AJcUukdRg7EJ/DxRP5MI9o3elV1TnX2Kg8CQNFv79OqQfcgHdVNGmiE7
	7hFxIEBm7XqrNoahQlI3BxamR4Was7lrI+HUDRcsz2FQ7B1ks1yXxNLZXz7q7Lu8K1xI/yBGOG1
	oIj7Z3Kh0x5TnRQ82mlj81nMmOWwjpgYfw6H9/nMfcFTVDE8QWDMPDFLiZrz3ance7jpc646mqS
	jiG2o1kYGZOKNm7UJwNgcr3bnRo6N18YXDdi4LkiNmp0OSyC5q8bzYGw2IkBsw+eyJ5LjZeEf80
	0jY/pBNB/haW90F1Y4/+q/C8C1ziUqFKiCY5kQb0iMz1tDtyLvNGJQE14oM84p8zN/0CSh0QdUQ
	zyCrW+Yjcw9Y8IQ8YpCMVGoUfzooX8xEly8WA+KR+Xwuw7b5+1EW9Sm7TGBfYV9CELoJwi+oZ+b
	N
X-Received: by 2002:a25:a4a2:: with SMTP id g31mr6559284ybi.1.1547055485817;
        Wed, 09 Jan 2019 09:38:05 -0800 (PST)
X-Received: by 2002:a25:a4a2:: with SMTP id g31mr6559232ybi.1.1547055484864;
        Wed, 09 Jan 2019 09:38:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547055484; cv=none;
        d=google.com; s=arc-20160816;
        b=va5gT6NHOIrK+Qhwz/D+6hObhFHqWlCzx6IMEzvxlZiA32k2tZXtcQMlmSKvJVvX2O
         auHP+lUtRGhFDYh4Kp7Ud+m194vX+vgGW9VFp1kU85hLAeTYppQRerzURvXNL8ywOakL
         c5NHwaccAW9xfEdaklZmDx+xxzaU+PENxmj4tvQ3qX5ya82VTEsteEQJfX53E+AarbFw
         a212+3YF/LI7hSVRbtgFjke1VobpS9ko+5wTTnAJ3/6VYBr8XaEFOh6uHSjont5TAlGP
         2oiDCzZbynVY32x+Vsvp2/ZJNRQDDvRCEWocptuW9bASR6Ti6/fLdNsftc96tQtUWaZI
         sdZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=00fTbS3NCEslFjaEEkgF4Su3Ks4m2l6BsBiP5Boa2l0=;
        b=CJkssbdPMxLOci6SNlEoOkLAnSyn0UWZdDpAA8PDTPo7OTIC1vTpSQSSeX4m5R81d1
         7zJbheZ2uCMB/7PUmyK64eK7jNAR8SIc/IuFoAsuqenQeI0lhAmRG77dDH6RgdIrJhwE
         C1WeJ9ck8oo8fPknyRGFGOwxDrDpjbzQytK8atXAgiWbR3GTFI1A8x3zWoFpQWA1A4oh
         aTbfFJJ8A6EMdzq8JFUFkZdRneG84cE7LOuN+uKYRxdBcsAGg0p2DaX4kTU4pl8E4wOm
         CvU3xurmHk7D3LYduu/pKonZeIXx3lgrv3qPLuNp8fwfZ5/mKHYjtKmvhRBIXFKEMcn2
         vITg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=PCmVpAsT;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y127sor9806128ywf.195.2019.01.09.09.38.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 Jan 2019 09:38:04 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=PCmVpAsT;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=00fTbS3NCEslFjaEEkgF4Su3Ks4m2l6BsBiP5Boa2l0=;
        b=PCmVpAsT+zT4tvr3NYlV7WkaIrd9SDdr0dOP0bDElU4rjd0kgShYNDaJsWYaMATLVM
         mWhX3zIqkfy2vURZrofhnbYPUt78gWs35gBHEvEV/9o9/OUJZJ9hnpMhAtp9WT2+SGPG
         yQiUiwrRl9dKDm5KkL+pKXUNKQxGIuQ61Mp45bV9a8BteD03F8ouB8lIpATOHSA7RUTQ
         zD7kfiigA5E6jUpgnrSJDgZzUA5EY8uFejYCcJ4Jgq1/F5uHMCMzKSwCtfwikHGl/lek
         JqSG7s8ChVg/+6DrZr90++om9d8bky1bZG7kS58De6g0V4RvyLG9gr+KlWn60dr4rZu2
         DlzQ==
X-Google-Smtp-Source: ALg8bN57H/xAyC2kQEXdOlJi75TH6rsY4BdsLEvYyP7t3iV+HBl4QZZqqeG4geAxtznaNW6/dV4ksjIoDfRK7ntaGWM=
X-Received: by 2002:a81:60c4:: with SMTP id u187mr6514817ywb.345.1547055483981;
 Wed, 09 Jan 2019 09:38:03 -0800 (PST)
MIME-Version: 1.0
References: <154703479840.32690.6504699919905946726.stgit@localhost.localdomain>
In-Reply-To: <154703479840.32690.6504699919905946726.stgit@localhost.localdomain>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 9 Jan 2019 09:37:52 -0800
Message-ID:
 <CALvZod63z5_m-izxFh4XQvjcALqffkZ5G91-KsyOuAC4wvN3Wg@mail.gmail.com>
Subject: Re: [PATCH RFC 0/3] mm: Reduce IO by improving algorithm of memcg
 pagecache pages eviction
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, josef@toxicpanda.com, 
	Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, 
	"Darrick J. Wong" <darrick.wong@oracle.com>, Michal Hocko <mhocko@suse.com>, 
	Andrey Ryabinin <aryabinin@virtuozzo.com>, Roman Gushchin <guro@fb.com>, 
	Mel Gorman <mgorman@techsingularity.net>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190109173752.yvc9HstmxatnE4iNBdpeIHr9JNTkfUfJn89EIdcYP9U@z>

Hi Kirill,

On Wed, Jan 9, 2019 at 4:20 AM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>
> On nodes without memory overcommit, it's common a situation,
> when memcg exceeds its limit and pages from pagecache are
> shrinked on reclaim, while node has a lot of free memory.
> Further access to the pages requires real device IO, while
> IO causes time delays, worse powerusage, worse throughput
> for other users of the device, etc.
>
> Cleancache is not a good solution for this problem, since
> it implies copying of page on every cleancache_put_page()
> and cleancache_get_page(). Also, it requires introduction
> of internal per-cleancache_ops data structures to manage
> cached pages and their inodes relationships, which again
> introduces overhead.
>
> This patchset introduces another solution. It introduces
> a new scheme for evicting memcg pages:
>
>   1)__remove_mapping() uncharges unmapped page memcg
>     and leaves page in pagecache on memcg reclaim;
>
>   2)putback_lru_page() places page into root_mem_cgroup
>     list, since its memcg is NULL. Page may be evicted
>     on global reclaim (and this will be easily, as
>     page is not mapped, so shrinker will shrink it
>     with 100% probability of success);
>
>   3)pagecache_get_page() charges page into memcg of
>     a task, which takes it first.
>

From what I understand from the proposal, on memcg reclaim, the file
pages are uncharged but kept in the memory and if they are accessed
again (either through mmap or syscall), they will be charged again but
to the requesting memcg. Also it is assumed that the global reclaim of
such uncharged file pages is very fast and deterministic. Is that
right?

Shakeel

> Below is small test, which shows profit of the patchset.
>
> Create memcg with limit 20M (exact value does not matter much):
>   $ mkdir /sys/fs/cgroup/memory/ct
>   $ echo 20M > /sys/fs/cgroup/memory/ct/memory.limit_in_bytes
>   $ echo $$ > /sys/fs/cgroup/memory/ct/tasks
>
> Then twice read 1GB file:
>   $ time cat file_1gb > /dev/null
>
> Before (2 iterations):
>   1)0.01user 0.82system 0:11.16elapsed 7%CPU
>   2)0.01user 0.91system 0:11.16elapsed 8%CPU
>
> After (2 iterations):
>   1)0.01user 0.57system 0:11.31elapsed 5%CPU
>   2)0.00user 0.28system 0:00.28elapsed 100%CPU
>
> With the patch set applied, we have file pages are cached
> during the second read, so the result is 39 times faster.
>
> This may be useful for slow disks, NFS, nodes without
> overcommit by memory, in case of two memcg access the same
> files, etc.
>
> ---
>
> Kirill Tkhai (3):
>       mm: Uncharge and keep page in pagecache on memcg reclaim
>       mm: Recharge page memcg on first get from pagecache
>       mm: Pass FGP_NOWAIT in generic_file_buffered_read and enable ext4
>
>
>  fs/ext4/inode.c         |    1 +
>  include/linux/pagemap.h |    1 +
>  mm/filemap.c            |   38 ++++++++++++++++++++++++++++++++++++--
>  mm/vmscan.c             |   22 ++++++++++++++++++----
>  4 files changed, 56 insertions(+), 6 deletions(-)
>
> --
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

