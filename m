Message-ID: <418122C6.7050303@us.ibm.com>
Date: Thu, 28 Oct 2004 09:48:06 -0700
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [2/7] 060 refactor setup_memory i386
References: <E1CNBE0-0006bV-ML@ladymac.shadowen.org> <41811566.2070200@us.ibm.com> <4181168B.3060209@shadowen.org>
In-Reply-To: <4181168B.3060209@shadowen.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: lhms-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andy Whitcroft wrote:
> That is a pre-declaration.  There is only one copy of 
> setup_bootmem_allocator() which is either used 'here' in the flatmem 
> case, or from discontig.c in the DISCONTIGMEM case.  The order is 
> backwards to minimise the overall diff; so I needed to declare it.

Ahhh, I just parsed that wrong.  Silly me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
