Received: by yw-out-1718.google.com with SMTP id 5so143192ywm.26
        for <linux-mm@kvack.org>; Wed, 14 May 2008 23:33:28 -0700 (PDT)
Message-ID: <386072610805142333vfc07709xe7a78b2a68cff2dd@mail.gmail.com>
Date: Thu, 15 May 2008 14:33:26 +0800
From: "Bryan Wu" <cooloney@kernel.org>
Subject: Re: [PATCH 2/4] [NOMMU]: include the problematic mapping in the munmap warning
In-Reply-To: <1210588325-11027-3-git-send-email-cooloney@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1210588325-11027-1-git-send-email-cooloney@kernel.org>
	 <1210588325-11027-3-git-send-email-cooloney@kernel.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dwmw2@infradead.org
Cc: Mike Frysinger <vapier.adi@gmail.com>, Bryan Wu <cooloney@kernel.org>
List-ID: <linux-mm.kvack.org>

IMO, this is useful for nommu stuff.
Is there any chance to merge this?

-Bryan

On Mon, May 12, 2008 at 6:32 PM, Bryan Wu <cooloney@kernel.org> wrote:
> From: Mike Frysinger <vapier.adi@gmail.com>
>
> Signed-off-by: Mike Frysinger <vapier.adi@gmail.com>
> Signed-off-by: Bryan Wu <cooloney@kernel.org>
> ---
>  mm/nommu.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/mm/nommu.c b/mm/nommu.c
> index ef8c62c..c11e5cc 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -1117,8 +1117,9 @@ int do_munmap(struct mm_struct *mm, unsigned long addr, size_t len)
>                        goto found;
>        }
>
> -       printk("munmap of non-mmaped memory by process %d (%s): %p\n",
> -              current->pid, current->comm, (void *) addr);
> +       printk(KERN_NOTICE "munmap of non-mmaped memory [%p-%p] by process %d (%s)\n",
> +              (void *)addr, (void *)addr+len, current->pid, current->comm);
> +
>        return -EINVAL;
>
>  found:
> --
> 1.5.5
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
