Date: Tue, 7 Oct 2008 10:20:30 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH, RFC, v2] shmat: introduce flag SHM_MAP_HINT
Message-ID: <20081007082030.GD20740@one.firstfloor.org>
References: <20081006192923.GJ3180@one.firstfloor.org> <1223362670-5187-1-git-send-email-kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1223362670-5187-1-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@redhat.com>, Arjan van de Ven <arjan@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 07, 2008 at 09:57:50AM +0300, Kirill A. Shutemov wrote:
> It allows interpret attach address as a hint, not as exact address.

Please expand the description a bit. Rationale. etc.

> @@ -55,6 +55,7 @@ struct shmid_ds {
>  #define	SHM_RND		020000	/* round attach address to SHMLBA boundary */
>  #define	SHM_REMAP	040000	/* take-over region on attach */
>  #define	SHM_EXEC	0100000	/* execution access */
> +#define	SHM_MAP_HINT	0200000	/* interpret attach address as a hint */

search hint

> @@ -892,7 +892,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr)
>  	sfd->vm_ops = NULL;
>  
>  	down_write(&current->mm->mmap_sem);
> -	if (addr && !(shmflg & SHM_REMAP)) {
> +	if (addr && !(shmflg & (SHM_REMAP|SHM_MAP_HINT))) {

I think you were right earlier that it can be just deleted, so why don't
you just do that?

-Andi

-- 
ak@linux.intel.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
