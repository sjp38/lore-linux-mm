Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 16EA56B0044
	for <linux-mm@kvack.org>; Sat, 28 Apr 2012 09:32:37 -0400 (EDT)
Received: by yenm8 with SMTP id m8so1230437yen.14
        for <linux-mm@kvack.org>; Sat, 28 Apr 2012 06:32:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120427123901.2132.47969.stgit@zurg>
References: <4F91BC8A.9020503@parallels.com> <20120427123901.2132.47969.stgit@zurg>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Sat, 28 Apr 2012 09:32:15 -0400
Message-ID: <CAHGf_=riWBO6-Ax0hfSU3hhxr7oXwLwtzJC55yeEpZDOjbqREg@mail.gmail.com>
Subject: Re: [PATCH 1/2] proc: report file/anon bit in /proc/pid/pagemap
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Pavel Emelyanov <xemul@parallels.com>

> diff --git a/Documentation/vm/pagemap.txt b/Documentation/vm/pagemap.txt
> index 4600cbe..7587493 100644
> --- a/Documentation/vm/pagemap.txt
> +++ b/Documentation/vm/pagemap.txt
> @@ -16,7 +16,7 @@ There are three components to pagemap:
> =A0 =A0 * Bits 0-4 =A0 swap type if swapped
> =A0 =A0 * Bits 5-54 =A0swap offset if swapped
> =A0 =A0 * Bits 55-60 page shift (page size =3D 1<<page shift)
> - =A0 =A0* Bit =A061 =A0 =A0reserved for future use
> + =A0 =A0* Bit =A061 =A0 =A0page is file-page or shared-anon
> =A0 =A0 * Bit =A062 =A0 =A0page swapped
> =A0 =A0 * Bit =A063 =A0 =A0page present

hmm..
Here says, file or shmem.


> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 2d60492..bc3df31 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -700,6 +700,7 @@ struct pagemapread {
>
> =A0#define PM_PRESENT =A0 =A0 =A0 =A0 =A0PM_STATUS(4LL)
> =A0#define PM_SWAP =A0 =A0 =A0 =A0 =A0 =A0 PM_STATUS(2LL)
> +#define PM_FILE =A0 =A0 =A0 =A0 =A0 =A0 PM_STATUS(1LL)
> =A0#define PM_NOT_PRESENT =A0 =A0 =A0PM_PSHIFT(PAGE_SHIFT)
> =A0#define PM_END_OF_BUFFER =A0 =A01

But, this macro says it's file. it seems a bit misleading. ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
