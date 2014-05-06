Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id A9E806B0035
	for <linux-mm@kvack.org>; Tue,  6 May 2014 16:40:44 -0400 (EDT)
Received: by mail-qg0-f44.google.com with SMTP id i50so33368qgf.31
        for <linux-mm@kvack.org>; Tue, 06 May 2014 13:40:44 -0700 (PDT)
Received: from mail-qg0-x236.google.com (mail-qg0-x236.google.com [2607:f8b0:400d:c04::236])
        by mx.google.com with ESMTPS id g10si3416741qge.17.2014.05.06.13.40.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 13:40:44 -0700 (PDT)
Received: by mail-qg0-f54.google.com with SMTP id q108so33130qgd.27
        for <linux-mm@kvack.org>; Tue, 06 May 2014 13:40:44 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <1399406800.13799.20.camel@buesod1.americas.hpqcorp.net>
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>
 <CAKgNAkjuU68hgyMOVGBVoBTOhhGdBytQh6H0ExiLoXfujKyP_w@mail.gmail.com> <1399406800.13799.20.camel@buesod1.americas.hpqcorp.net>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Tue, 6 May 2014 22:40:23 +0200
Message-ID: <CAKgNAkjOKP7P9veOpnokNkVXSszVZt5asFsNp7rm7AXJdjcLLA@mail.gmail.com>
Subject: Re: [PATCH 0/4] ipc/shm.c: increase the limits for SHMMAX, SHMALL
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Manfred Spraul <manfred@colorfullife.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, aswin@hp.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Davidlohr,

On Tue, May 6, 2014 at 10:06 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> On Fri, 2014-05-02 at 15:16 +0200, Michael Kerrisk (man-pages) wrote:
>> Hi Manfred,
>>
>> On Mon, Apr 21, 2014 at 4:26 PM, Manfred Spraul
>> <manfred@colorfullife.com> wrote:
>> > Hi all,
>> >
>> > the increase of SHMMAX/SHMALL is now a 4 patch series.
>> > I don't have ideas how to improve it further.
>>
>> On the assumption that your patches are heading to mainline, could you
>> send me a man-pages patch for the changes?
>
> Btw, I think that the code could still use some love wrt documentation.

(Agreed.)

> Andrew, please consider this for -next if folks agree. Thanks.
>
> 8<----------------------------------------------------------
>
> From: Davidlohr Bueso <davidlohr@hp.com>
> Subject: [PATCH] ipc,shm: document new limits in the uapi header
>
> This is useful in the future and allows users to
> better understand the reasoning behind the changes.
>
> Also use UL as we're dealing with it anyways.
>
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> ---
>  include/uapi/linux/shm.h | 14 ++++++++------
>  1 file changed, 8 insertions(+), 6 deletions(-)
>
> diff --git a/include/uapi/linux/shm.h b/include/uapi/linux/shm.h
> index 74e786d..e37fb08 100644
> --- a/include/uapi/linux/shm.h
> +++ b/include/uapi/linux/shm.h
> @@ -8,17 +8,19 @@
>  #endif
>
>  /*
> - * SHMMAX, SHMMNI and SHMALL are upper limits are defaults which can

Something is wrong in the line above (missing word(s)?) ("are upper
limits are defaults")

> - * be modified by sysctl.
> + * SHMMNI, SHMMAX and SHMALL are the default upper limits which can be
> + * modified by sysctl. Both SHMMAX and SHMALL have their default values
> + * to the maximum limit which is as large as it can be without helping
> + * userspace overflow the values. There is really nothing the kernel
> + * can do to avoid this any variables. It is therefore not advised to

Something is missing in that last line.

> + * make them any larger. This is suitable for both 32 and 64-bit systems.

"This" is not so clear. I suggest replacing with an actual noun.

>   */
> -
>  #define SHMMIN 1                        /* min shared seg size (bytes) */
>  #define SHMMNI 4096                     /* max num of segs system wide */
> -#define SHMMAX (ULONG_MAX - (1L<<24))   /* max shared seg size (bytes) */
> -#define SHMALL (ULONG_MAX - (1L<<24))   /* max shm system wide (pages) */
> +#define SHMMAX (ULONG_MAX - (1UL << 24)) /* max shared seg size (bytes) */
> +#define SHMALL (ULONG_MAX - (1UL << 24)) /* max shm system wide (pages) */
>  #define SHMSEG SHMMNI                   /* max shared segs per process */
>
> -
>  /* Obsolete, used only for backwards compatibility and libc5 compiles */
>  struct shmid_ds {
>         struct ipc_perm         shm_perm;       /* operation perms */

Cheers,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
