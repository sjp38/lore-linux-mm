Subject: Re: TLB flush optimization on s/390.
Message-ID: <OFF67143AC.941FD14C-ONC1256DBB.002D6C6B-C1256DBB.002DCC69@de.ibm.com>
From: "Martin Schwidefsky" <schwidefsky@de.ibm.com>
Date: Fri, 10 Oct 2003 10:20:14 +0200
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: akpm@osdl.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, willy@debian.org
List-ID: <linux-mm.kvack.org>

> > -static int
> > -copy_one_pte(struct mm_struct *mm, pte_t *src, pte_t *dst,
> > -                    struct pte_chain **pte_chainp)
> > +static inline int
> > +copy_one_pte(struct vm_area_struct *vma, unsigned long old_addr,
> > +             pte_t *src, pte_t *dst, struct pte_chain **pte_chainp)
>
> There is no way you should start inling this.

Would you care to explain why this is a problem? It's a static function
that gets folded into another static function. I added additional arguments
to copy_one_pte and to avoid to make move_one_page slower I though to
inline it would be a good idea.

blue skies,
   Martin


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
