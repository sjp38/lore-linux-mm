Date: Fri, 10 Oct 2003 00:00:32 -0700
From: "David S. Miller" <davem@redhat.com>
Subject: Re: TLB flush optimization on s/390.
Message-Id: <20031010000032.15664481.davem@redhat.com>
In-Reply-To: <20031009123844.GA464@mschwid3.boeblingen.de.ibm.com>
References: <20031009123844.GA464@mschwid3.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: akpm@osdl.org, willy@debian.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 9 Oct 2003 14:38:45 +0200
Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:

> Ok, renamed three of the new functions. Patch @EOM.

I'm fine with everything except this:

> -static int
> -copy_one_pte(struct mm_struct *mm, pte_t *src, pte_t *dst,
> -		struct pte_chain **pte_chainp)
> +static inline int
> +copy_one_pte(struct vm_area_struct *vma, unsigned long old_addr,
> +	     pte_t *src, pte_t *dst, struct pte_chain **pte_chainp)

There is no way you should start inling this.

At best, you should suggest such a change seperately from these API
changes you are proposing.  When you mix multiple changes together you
risk the whole patch being rejected, so please avoid this in the
future.

Thanks.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
