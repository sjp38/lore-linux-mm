Date: Mon, 5 Nov 2007 20:38:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [git Patch] mm/util.c: Remove needless code
Message-Id: <20071105203816.3f8b2e7a.akpm@linux-foundation.org>
In-Reply-To: <20071106031207.GA2478@hacking>
References: <20071106031207.GA2478@hacking>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: WANG Cong <xiyou.wangcong@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Dong Pu <cocobear.cn@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, 6 Nov 2007 11:12:07 +0800 WANG Cong <xiyou.wangcong@gmail.com> wrote:

> 
> If the code can be executed there, 'new_size' is always larger
> than 'ks'. Thus min() is needless.
> 
> Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>
> Signed-off-by: Dong Pu <cocobear.cn@gmail.com>
> Cc: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  mm/util.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/util.c b/mm/util.c
> index 5f64026..295c7aa 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -96,7 +96,7 @@ void *krealloc(const void *p, size_t new_size, gfp_t flags)
>  
>  	ret = kmalloc_track_caller(new_size, flags);
>  	if (ret) {
> -		memcpy(ret, p, min(new_size, ks));
> +		memcpy(ret, p, ks);
>  		kfree(p);
>  	}
>  	return ret;

Thanks.  This was already fixed by

http://www.mail-archive.com/mm-commits@vger.kernel.org/msg28294.html

(which is somewhere in one of my ever-growing number of for-2.6.24 queues)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
