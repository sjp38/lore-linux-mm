Message-ID: <437B3349.8050308@shadowen.org>
Date: Wed, 16 Nov 2005 13:25:29 +0000
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: pfn_to_nid under CONFIG_SPARSEMEM and CONFIG_NUMA
References: <20051115221003.GA2160@w-mikek2.ibm.com>
In-Reply-To: <20051115221003.GA2160@w-mikek2.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Kravetz <kravetz@us.ibm.com>
Cc: linux-mm@kvack.org, Anton Blanchard <anton@samba.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Mike Kravetz wrote:
> The following code/comment is in <linux/mmzone.h> if SPARSEMEM
> and NUMA are configured.
> 
> /*
>  * These are _only_ used during initialisation, therefore they
>  * can use __initdata ...  They could have names to indicate
>  * this restriction.
>  */
> #ifdef CONFIG_NUMA
> #define pfn_to_nid              early_pfn_to_nid
> #endif

Ok.  This was a ploy to avoid lots of code churn which has bitten us.
The separation here is to indicate that pfn_to_nid isn't necessarily
safe until after the memory model is init'd.  When the code was
initially implmented we only used pfn_to_nid in init code so it wasn't
an issue.  What we need to do here is break this link and make sure each
user is using the right version.

I'll go and put together something now.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
