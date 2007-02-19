Subject: Re: [PATCH 1/7] Introduce the pagetable_operations and associated
	helper macros.
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <20070219183133.27318.92920.stgit@localhost.localdomain>
References: <20070219183123.27318.27319.stgit@localhost.localdomain>
	 <20070219183133.27318.92920.stgit@localhost.localdomain>
Content-Type: text/plain
Date: Mon, 19 Feb 2007 19:41:23 +0100
Message-Id: <1171910483.3531.87.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2007-02-19 at 10:31 -0800, Adam Litke wrote:
> Signed-off-by: Adam Litke <agl@us.ibm.com>
> ---
> 
>  include/linux/mm.h |   25 +++++++++++++++++++++++++
>  1 files changed, 25 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 2d2c08d..a2fa66d 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -98,6 +98,7 @@ struct vm_area_struct {
>  
>  	/* Function pointers to deal with this struct. */
>  	struct vm_operations_struct * vm_ops;
> +	struct pagetable_operations_struct * pagetable_ops;
>  

please make it at least const, those things have no business ever being
written to right? And by making them const the compiler helps catch
that, and as bonus the data gets moved to rodata so that it won't share
cachelines with anything that gets dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
