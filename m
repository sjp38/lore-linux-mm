Message-ID: <4234E466.1020002@osdl.org>
Date: Sun, 13 Mar 2005 17:09:58 -0800
From: "Randy.Dunlap" <rddunlap@osdl.org>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC] io_remap_pfn_range()
References: <20050310144256.31eb9420.rddunlap@osdl.org>
In-Reply-To: <20050310144256.31eb9420.rddunlap@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Randy.Dunlap" <rddunlap@osdl.org>
Cc: linux-mm@kvack.org, sparclinux@vger.kernel.org, ultralinux@vger.kernel.org, davem@davemloft.net, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

Randy.Dunlap wrote:

(add)
consolidate io_remap_pfn_range() so that different arches
don't use different parameters for io_remap_page_range();

> io_remap_pfn_range():
>   add io_remap_pfn_range() for all arches;
>   eliminate the <iospace> parameter from sparc/sparc64;
>   add MK_IOSPACE_PFN(), GET_IOSPACE(), and GET_PFN()
> 	for all arches but primarily for sparc32/64's extended IO space,
>   sparc: kill the hack of using low bit of <offset> to mean
> 	write_combine or set side-effect (_PAGE_E) bit;
>   future: convert remaining callers of io_remap_page_range() to
> 	io_remap_pfn_range() and deprecate io_remap_page_range();
> 

BTW, built successfully on 8 arches, but needs testing
on sparc32/64, which I can't do.....

https://www.osdl.org/plm-cgi/plm?module=patch_info&patch_id=4270
build failures there are not related to this patch.

-- 
~Randy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
