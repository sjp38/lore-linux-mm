Received: by rv-out-0708.google.com with SMTP id f25so10905092rvb.26
        for <linux-mm@kvack.org>; Tue, 24 Jun 2008 10:38:47 -0700 (PDT)
Message-ID: <2f11576a0806241038s45a93ec0l54bd826973433c17@mail.gmail.com>
Date: Wed, 25 Jun 2008 02:38:47 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] fix2 to putback_lru_page()/unevictable page handling rework v3
In-Reply-To: <1214328572.6563.31.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080621185408.E832.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080624114006.D81C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <1214328572.6563.31.camel@lts-notebook>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
>
>  include/linux/mm.h |    7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
>
> Index: linux-2.6.26-rc5-mm3/include/linux/mm.h
> ===================================================================
> --- linux-2.6.26-rc5-mm3.orig/include/linux/mm.h        2008-06-24 12:54:41.000000000 -0400
> +++ linux-2.6.26-rc5-mm3/include/linux/mm.h     2008-06-24 13:25:29.000000000 -0400
> @@ -706,13 +706,12 @@ static inline int page_mapped(struct pag
>  extern void show_free_areas(void);
>
>  #ifdef CONFIG_SHMEM
> -extern struct address_space *shmem_lock(struct file *file, int lock,
> -                                       struct user_struct *user);
> +extern int shmem_lock(struct file *file, int lock, struct user_struct *user);
>  #else
> -static inline struct address_space *shmem_lock(struct file *file, int lock,
> +static inline int shmem_lock(struct file *file, int lock,
>                                        struct user_struct *user)
>  {
> -       return NULL;
> +       return 0;
>  }
>  #endif
>  struct file *shmem_file_setup(char *name, loff_t size, unsigned long flags);

Sure.
I forgot "quilt add mm.h" operation ;-)

Thank you!

     Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
