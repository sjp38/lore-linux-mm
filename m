Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A940C6B00D7
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 15:38:26 -0500 (EST)
Date: Tue, 9 Mar 2010 12:37:48 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] memory hotplug/s390: set phys_device
Message-Id: <20100309123748.3015e10a.akpm@linux-foundation.org>
In-Reply-To: <20100309172052.GC2360@osiris.boeblingen.de.ibm.com>
References: <20100309172052.GC2360@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gerald Schaefer <gerald.schaefer@de.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Mar 2010 18:20:52 +0100
Heiko Carstens <heiko.carstens@de.ibm.com> wrote:

> From: Heiko Carstens <heiko.carstens@de.ibm.com>
> 
> Implement arch specific arch_get_memory_phys_device function and initialize
> phys_device for each memory section. That way we finally can tell which
> piece of memory belongs to which physical device.
> 
> Cc: Dave Hansen <haveblue@us.ibm.com>
> Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by:  Heiko Carstens <heiko.carstens@de.ibm.com>
> ---
>  drivers/s390/char/sclp_cmd.c |    7 +++++++
>  1 file changed, 7 insertions(+)
> 
> --- a/drivers/s390/char/sclp_cmd.c
> +++ b/drivers/s390/char/sclp_cmd.c
> @@ -704,6 +704,13 @@ int sclp_chp_deconfigure(struct chp_id c
>  	return do_chp_configure(SCLP_CMDW_DECONFIGURE_CHPATH | chpid.id << 8);
>  }
>  
> +int arch_get_memory_phys_device(unsigned long start_pfn)
> +{
> +	if (!rzm)
> +		return 0;
> +	return PFN_PHYS(start_pfn) / rzm;
> +}
> +
>  struct chp_info_sccb {
>  	struct sccb_header header;
>  	u8 recognized[SCLP_CHP_INFO_MASK_SIZE];

What is the utility of this patch?  It makes s390's
/sys/devices/system/memory/memoryX/phys_device display the correct
thing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
