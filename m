Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id D0B938E0072
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 06:02:49 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id q3-v6so24799947otl.14
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 03:02:49 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m84-v6si781609oia.51.2018.09.25.03.02.48
        for <linux-mm@kvack.org>;
        Tue, 25 Sep 2018 03:02:48 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH V2] mm/hugetlb: Add mmap() encodings for 32MB and 512MB page sizes
References: <1537797985-2406-1-git-send-email-anshuman.khandual@arm.com>
	<1537841300-6979-1-git-send-email-anshuman.khandual@arm.com>
Date: Tue, 25 Sep 2018 11:02:45 +0100
In-Reply-To: <1537841300-6979-1-git-send-email-anshuman.khandual@arm.com>
	(Anshuman Khandual's message of "Tue, 25 Sep 2018 07:38:20 +0530")
Message-ID: <871s9hsxmi.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mike.kravetz@oracle.com, mhocko@kernel.org, will.deacon@arm.com, akpm@linux-foundation.org

Anshuman Khandual <anshuman.khandual@arm.com> writes:

> ARM64 architecture also supports 32MB and 512MB HugeTLB page sizes.
> This just adds mmap() system call argument encoding for them.
>
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>

Thanks for adding the encodings.

Acked-by: Punit Agrawal <punit.agrawal@arm.com>

> ---
>
> Changes in V2:
> - Updated SHM and MFD definitions per Mike
>
>  include/uapi/asm-generic/hugetlb_encode.h | 2 ++
>  include/uapi/linux/memfd.h                | 2 ++
>  include/uapi/linux/mman.h                 | 2 ++
>  include/uapi/linux/shm.h                  | 2 ++
>  4 files changed, 8 insertions(+)
>
> diff --git a/include/uapi/asm-generic/hugetlb_encode.h b/include/uapi/asm-generic/hugetlb_encode.h
> index e4732d3..b0f8e87 100644
> --- a/include/uapi/asm-generic/hugetlb_encode.h
> +++ b/include/uapi/asm-generic/hugetlb_encode.h
> @@ -26,7 +26,9 @@
>  #define HUGETLB_FLAG_ENCODE_2MB		(21 << HUGETLB_FLAG_ENCODE_SHIFT)
>  #define HUGETLB_FLAG_ENCODE_8MB		(23 << HUGETLB_FLAG_ENCODE_SHIFT)
>  #define HUGETLB_FLAG_ENCODE_16MB	(24 << HUGETLB_FLAG_ENCODE_SHIFT)
> +#define HUGETLB_FLAG_ENCODE_32MB	(25 << HUGETLB_FLAG_ENCODE_SHIFT)
>  #define HUGETLB_FLAG_ENCODE_256MB	(28 << HUGETLB_FLAG_ENCODE_SHIFT)
> +#define HUGETLB_FLAG_ENCODE_512MB	(29 << HUGETLB_FLAG_ENCODE_SHIFT)
>  #define HUGETLB_FLAG_ENCODE_1GB		(30 << HUGETLB_FLAG_ENCODE_SHIFT)
>  #define HUGETLB_FLAG_ENCODE_2GB		(31 << HUGETLB_FLAG_ENCODE_SHIFT)
>  #define HUGETLB_FLAG_ENCODE_16GB	(34 << HUGETLB_FLAG_ENCODE_SHIFT)
> diff --git a/include/uapi/linux/memfd.h b/include/uapi/linux/memfd.h
> index 015a4c0..7a8a267 100644
> --- a/include/uapi/linux/memfd.h
> +++ b/include/uapi/linux/memfd.h
> @@ -25,7 +25,9 @@
>  #define MFD_HUGE_2MB	HUGETLB_FLAG_ENCODE_2MB
>  #define MFD_HUGE_8MB	HUGETLB_FLAG_ENCODE_8MB
>  #define MFD_HUGE_16MB	HUGETLB_FLAG_ENCODE_16MB
> +#define MFD_HUGE_32MB	HUGETLB_FLAG_ENCODE_32MB
>  #define MFD_HUGE_256MB	HUGETLB_FLAG_ENCODE_256MB
> +#define MFD_HUGE_512MB	HUGETLB_FLAG_ENCODE_512MB
>  #define MFD_HUGE_1GB	HUGETLB_FLAG_ENCODE_1GB
>  #define MFD_HUGE_2GB	HUGETLB_FLAG_ENCODE_2GB
>  #define MFD_HUGE_16GB	HUGETLB_FLAG_ENCODE_16GB
> diff --git a/include/uapi/linux/mman.h b/include/uapi/linux/mman.h
> index bfd5938..d0f515d 100644
> --- a/include/uapi/linux/mman.h
> +++ b/include/uapi/linux/mman.h
> @@ -28,7 +28,9 @@
>  #define MAP_HUGE_2MB	HUGETLB_FLAG_ENCODE_2MB
>  #define MAP_HUGE_8MB	HUGETLB_FLAG_ENCODE_8MB
>  #define MAP_HUGE_16MB	HUGETLB_FLAG_ENCODE_16MB
> +#define MAP_HUGE_32MB	HUGETLB_FLAG_ENCODE_32MB
>  #define MAP_HUGE_256MB	HUGETLB_FLAG_ENCODE_256MB
> +#define MAP_HUGE_512MB	HUGETLB_FLAG_ENCODE_512MB
>  #define MAP_HUGE_1GB	HUGETLB_FLAG_ENCODE_1GB
>  #define MAP_HUGE_2GB	HUGETLB_FLAG_ENCODE_2GB
>  #define MAP_HUGE_16GB	HUGETLB_FLAG_ENCODE_16GB
> diff --git a/include/uapi/linux/shm.h b/include/uapi/linux/shm.h
> index dde1344..6507ad0 100644
> --- a/include/uapi/linux/shm.h
> +++ b/include/uapi/linux/shm.h
> @@ -65,7 +65,9 @@ struct shmid_ds {
>  #define SHM_HUGE_2MB	HUGETLB_FLAG_ENCODE_2MB
>  #define SHM_HUGE_8MB	HUGETLB_FLAG_ENCODE_8MB
>  #define SHM_HUGE_16MB	HUGETLB_FLAG_ENCODE_16MB
> +#define SHM_HUGE_32MB	HUGETLB_FLAG_ENCODE_32MB
>  #define SHM_HUGE_256MB	HUGETLB_FLAG_ENCODE_256MB
> +#define SHM_HUGE_512MB	HUGETLB_FLAG_ENCODE_512MB
>  #define SHM_HUGE_1GB	HUGETLB_FLAG_ENCODE_1GB
>  #define SHM_HUGE_2GB	HUGETLB_FLAG_ENCODE_2GB
>  #define SHM_HUGE_16GB	HUGETLB_FLAG_ENCODE_16GB
