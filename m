Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 24E356B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 08:48:16 -0400 (EDT)
Date: Tue, 28 Sep 2010 07:48:10 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 4/8] v2 Allow memory block to span multiple memory
 sections
Message-ID: <20100928124810.GI14068@sgi.com>
References: <4CA0EBEB.1030204@austin.ibm.com>
 <4CA0EFAA.8050000@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CA0EFAA.8050000@austin.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> +u32 __weak memory_block_size_bytes(void)
> +{
> +	return MIN_MEMORY_BLOCK_SIZE;
> +}
> +
> +static u32 get_memory_block_size(void)

Can we make this an unsigned long?  We are testing on a system whose
smallest possible configuration is 4GB per socket with 512 sockets.
We would like to be able to specify this as 2GB by default (results
in the least lost memory) and suggest we add a command line option
which overrides this value.  We have many installations where 16GB may
be optimal.  Large configurations will certainly become more prevalent.

...
> @@ -551,12 +608,16 @@
>  	unsigned int i;
>  	int ret;
>  	int err;
> +	int block_sz;

This one needs to match the return above.  In our tests, we ended up
with a negative sections_per_block which caused very unexpected results.

Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
