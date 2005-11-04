From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] powerpc: mem_init crash for sparsemem
Date: Fri, 4 Nov 2005 22:43:48 +0100
References: <200511041631.17237.arnd@arndb.de> <436BC20B.9070704@shadowen.org>
In-Reply-To: <436BC20B.9070704@shadowen.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Message-Id: <200511042243.49661.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linuxppc64-dev@ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Freedag 04 November 2005 21:18, Andy Whitcroft wrote:
> Would it not make sense to use pfn_valid(), as that is not sparsemem
> specific?  Not looked at the code in question specifically, but if you
> can use section_has_mem_map() it should be equivalent:
> 
>         if (!pfn_valid(pgdat->node_start_pfn + i))
>                 continue;
> 
> Want to spin us a patch and I'll give it some general testing.

Yes, I guess pfn_valid() is the function I was looking for, thanks
for pointing that out.

Unfortunately, I don't have access to the machine over the weekend,
so I won't be able to test that until Monday.

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
