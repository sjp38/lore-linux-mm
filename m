Date: Tue, 13 May 2008 11:09:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] [mm] buddy page allocator: add tunable big order
 allocation
Message-Id: <20080513110902.80a87ac9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1210588325-11027-2-git-send-email-cooloney@kernel.org>
References: <1210588325-11027-1-git-send-email-cooloney@kernel.org>
	<1210588325-11027-2-git-send-email-cooloney@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bryan Wu <cooloney@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dwmw2@infradead.org, Michael Hennerich <michael.hennerich@analog.com>
List-ID: <linux-mm.kvack.org>

On Mon, 12 May 2008 18:32:02 +0800
Bryan Wu <cooloney@kernel.org> wrote:

> From: Michael Hennerich <michael.hennerich@analog.com>
> 
> Signed-off-by: Michael Hennerich <michael.hennerich@analog.com>
> Signed-off-by: Bryan Wu <cooloney@kernel.org>

Does this really solve your problem ? possible hang-up is better than
page allocation failure ?

> ---
>  init/Kconfig    |    9 +++++++++
>  mm/page_alloc.c |    2 +-
>  2 files changed, 10 insertions(+), 1 deletions(-)
> 
> diff --git a/init/Kconfig b/init/Kconfig
> index 6135d07..b6ff75b 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -742,6 +742,15 @@ config SLUB_DEBUG
>  	  SLUB sysfs support. /sys/slab will not exist and there will be
>  	  no support for cache validation etc.
>  
> +config BIG_ORDER_ALLOC_NOFAIL_MAGIC
> +	int "Big Order Allocation No FAIL Magic"
> +	depends on EMBEDDED
> +	range 3 10
> +	default 3
> +	help
> +	  Let big-order allocations loop until memory gets free. Specified Value
> +	  expresses the order.
> +
I think it's better to add a text to explain why this is for EMBEDED.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
