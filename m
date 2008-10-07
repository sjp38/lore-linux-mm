Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m97B8KIJ010212
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 7 Oct 2008 20:08:21 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C076E2AC026
	for <linux-mm@kvack.org>; Tue,  7 Oct 2008 20:08:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9434E12C047
	for <linux-mm@kvack.org>; Tue,  7 Oct 2008 20:08:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D0051DB8045
	for <linux-mm@kvack.org>; Tue,  7 Oct 2008 20:08:20 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D22B51DB8048
	for <linux-mm@kvack.org>; Tue,  7 Oct 2008 20:08:19 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH, RFC] shmat: introduce flag SHM_MAP_HINT
In-Reply-To: <1223303879-5555-1-git-send-email-kirill@shutemov.name>
References: <20081006132651.GG3180@one.firstfloor.org> <1223303879-5555-1-git-send-email-kirill@shutemov.name>
Message-Id: <20081007195837.5A6B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  7 Oct 2008 20:08:19 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@redhat.com>, Arjan van de Ven <arjan@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> It allows interpret attach address as a hint, not as exact address.
> 
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: Andi Kleen <andi@firstfloor.org>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Arjan van de Ven <arjan@infradead.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  include/linux/shm.h |    1 +
>  ipc/shm.c           |    4 ++--
>  2 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/shm.h b/include/linux/shm.h
> index eca6235..2a637b8 100644
> --- a/include/linux/shm.h
> +++ b/include/linux/shm.h
> @@ -55,6 +55,7 @@ struct shmid_ds {
>  #define	SHM_RND		020000	/* round attach address to SHMLBA boundary */
>  #define	SHM_REMAP	040000	/* take-over region on attach */
>  #define	SHM_EXEC	0100000	/* execution access */
> +#define	SHM_MAP_HINT	0200000	/* interpret attach address as a hint */

hmm..
Honestly, I don't like that qemu specific feature insert into shmem core.
At least, this patch is too few comments.
Therefore, an develpper can't understand why SHM_MAP_HINT exist.

I think this patch description is too short and too poor.
I don't like increasing mysterious interface.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
