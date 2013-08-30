Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 12A076B0033
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 07:56:53 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH 2/4] mm/acpi: use NUMA_NO_NODE
Date: Fri, 30 Aug 2013 14:07:37 +0200
Message-ID: <1489693.CsKFcLgBvu@vostro.rjw.lan>
In-Reply-To: <521FF494.6000504@huawei.com>
References: <521FF494.6000504@huawei.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, lenb@kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Friday, August 30, 2013 09:25:40 AM Jianguo Wu wrote:
> Use more appropriate NUMA_NO_NODE instead of -1
> 
> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>

I'll queue this up for 3.13.

Thanks,
Rafael


> ---
>  drivers/acpi/acpi_memhotplug.c |    2 +-
>  drivers/acpi/numa.c            |    4 ++--
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
> index 999adb5..c00a3a7 100644
> --- a/drivers/acpi/acpi_memhotplug.c
> +++ b/drivers/acpi/acpi_memhotplug.c
> @@ -281,7 +281,7 @@ static void acpi_memory_remove_memory(struct acpi_memory_device *mem_device)
>  		if (!info->enabled)
>  			continue;
>  
> -		if (nid < 0)
> +		if (nid == NUMA_NO_NODE)
>  			nid = memory_add_physaddr_to_nid(info->start_addr);
>  
>  		acpi_unbind_memory_blocks(info, handle);
> diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
> index 33e609f..09f79a2 100644
> --- a/drivers/acpi/numa.c
> +++ b/drivers/acpi/numa.c
> @@ -73,7 +73,7 @@ int acpi_map_pxm_to_node(int pxm)
>  {
>  	int node = pxm_to_node_map[pxm];
>  
> -	if (node < 0) {
> +	if (node == NUMA_NO_NODE) {
>  		if (nodes_weight(nodes_found_map) >= MAX_NUMNODES)
>  			return NUMA_NO_NODE;
>  		node = first_unset_node(nodes_found_map);
> @@ -334,7 +334,7 @@ int acpi_get_pxm(acpi_handle h)
>  
>  int acpi_get_node(acpi_handle *handle)
>  {
> -	int pxm, node = -1;
> +	int pxm, node = NUMA_NO_NODE;
>  
>  	pxm = acpi_get_pxm(handle);
>  	if (pxm >= 0 && pxm < MAX_PXM_DOMAINS)
> 
-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
