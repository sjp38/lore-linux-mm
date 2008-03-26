Date: Wed, 26 Mar 2008 22:49:39 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/4] allow arch specific function for allocating gigantic pages
Message-ID: <20080326214939.GB29105@one.firstfloor.org>
References: <47EABE2D.7080400@linux.vnet.ibm.com> <47EABF09.6090302@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <47EABF09.6090302@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jon Tollefson <kniht@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@ozlabs.org>, Adam Litke <agl@linux.vnet.ibm.com>, Andi Kleen <andi@firstfloor.org>, Paul Mackerras <paulus@samba.org>, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Haven't reviewed it in detail, just noticed something.

> @@ -614,6 +610,7 @@ static int __init hugetlb_init(void)
>  {
>  	if (HPAGE_SHIFT == 0)
>  		return 0;
> +	INIT_LIST_HEAD(&huge_boot_pages);
>  	return hugetlb_init_hstate(&global_hstate);

I don't think adding the INIT_LIST_HEAD here is correct. There can
be huge pages added by the __setup handlers before hugetlb_init

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
