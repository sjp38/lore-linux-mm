Date: Wed, 11 Sep 2002 08:05:05 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH] Config.help entry for CONFIG_HUGETLB_PAGE
Message-ID: <480345900.1031731504@[10.10.2.3]>
In-Reply-To: <1031755731.1990.262.camel@spc9.esa.lanl.gov>
References: <1031755731.1990.262.camel@spc9.esa.lanl.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Cole <elenstev@mesatop.com>, Andrew Morton <akpm@zip.com.au>
Cc: "Seth, Rohit" <rohit.seth@intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 
> +CONFIG_HUGETLB_PAGE
> +  This enables support for huge pages (4MB for x86).  User space
> +  applications can make use of this support with the sys_alloc_hugepages
> +  and sys_free_hugepages system calls.  If your applications are
> +  huge page aware and your processor (Pentium or later for x86) supports
> +  this, then say Y here.
> +
> +  Otherwise, say N.

They're not always 4Mb on x86 ... they're 2Mb if you have PAE 
turned on ... maybe just leave out the "(4MB for x86)" comment?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
