Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 413EB6B00CB
	for <linux-mm@kvack.org>; Sun, 17 Feb 2013 02:28:20 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so2053731dak.28
        for <linux-mm@kvack.org>; Sat, 16 Feb 2013 23:28:19 -0800 (PST)
Message-ID: <5120868D.2090806@gmail.com>
Date: Sun, 17 Feb 2013 15:28:13 +0800
From: Will Huck <will.huckk@gmail.com>
MIME-Version: 1.0
Subject: Re: [LSF/MM TOPIC][ATTEND] a few topics I'd like to discuss
References: <CAHGf_=rb0t4gbm0Egw9D3RUuwbgL8U6hPwBwS46C27mgAvJp0g@mail.gmail.com>
In-Reply-To: <CAHGf_=rb0t4gbm0Egw9D3RUuwbgL8U6hPwBwS46C27mgAvJp0g@mail.gmail.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 02/17/2013 02:44 PM, KOSAKI Motohiro wrote:
> Sorry for the delay.
>
> I would like to discuss the following topics:
>
>
>
> * Hugepage migration ? Currently, hugepage is not migratable and can?t
> use pages in ZONE_MOVABLE.  It is not happy from point of CMA/hotplug
> view.

Why CMA not happy? unmovable pages can't alloc from CMA range.

>
> * Remove ZONE_MOVABLE ?Very long term goal. Maybe not suitable in this year.
>
> * Mempolicy rebinding rework ? current mempolicy rebinding has a lot
> of limitations.
>
>    - no rebinding when hotplug
>
>    - no rebinding when using shm memplicy
>
>    - broken argument check when MPOL_DEFAULT
>
> * Rework shared mempolicy ? shared mempolicy don?t work correctly when
> attached from multiple processes. However shmem exist for inter
> process  communication.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=ilto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
