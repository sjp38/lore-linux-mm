From: Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH] mm/rmap: replace BUG_ON(anon_vma->degree) with VM_WARN_ON
Date: Thu, 31 Mar 2016 14:49:18 +0200
Message-ID: <56FD1CCE.3020809@suse.cz>
References: <145941463036.29562.15629573511013443187.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <145941463036.29562.15629573511013443187.stgit@buzz>
Sender: linux-kernel-owner@vger.kernel.org
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
List-Id: linux-mm.kvack.org

On 03/31/2016 10:57 AM, Konstantin Khlebnikov wrote:
> This check effectively catches anon vma hierarchy inconsistence and some
> vma corruptions. It was effective for catching corner cases in anon vma
> reusing logic. For now this code seems stable so check could be hidden
> under CONFIG_DEBUG_VM and replaced with WARN because it's not so fatal.
>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Suggested-by: Vasily Averin <vvs@virtuozzo.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   mm/rmap.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 395e314b7996..a8d52d3f40ed 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -409,7 +409,7 @@ void unlink_anon_vmas(struct vm_area_struct *vma)
>   	list_for_each_entry_safe(avc, next, &vma->anon_vma_chain, same_vma) {
>   		struct anon_vma *anon_vma = avc->anon_vma;
>
> -		BUG_ON(anon_vma->degree);
> +		VM_WARN_ON(anon_vma->degree);
>   		put_anon_vma(anon_vma);
>
>   		list_del(&avc->same_vma);
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
