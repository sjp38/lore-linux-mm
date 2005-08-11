Date: Thu, 11 Aug 2005 15:37:35 -0700 (PDT)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low() ver. 2.
In-Reply-To: <20050811211419.GB5213@w-mikek2.ibm.com>
Message-ID: <Pine.LNX.4.62.0508111425070.20351@graphe.net>
References: <20050809194115.C370.Y-GOTO@jp.fujitsu.com>
 <20050809211501.GB6235@w-mikek2.ibm.com> <Pine.LNX.4.62.0508111343300.19728@graphe.net>
 <20050811211419.GB5213@w-mikek2.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Kravetz <kravetz@us.ibm.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, "Martin J. Bligh" <mbligh@mbligh.org>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, 11 Aug 2005, Mike Kravetz wrote:

> In alphabetical order I first looked at alpha and things didn't look the 
> same in the '#ifndef USE_48_BIT_KSEG' case.  When I first looked at 
> this, I quit after looking at alpha.  However, I can't seem to easily 
> find other archs that differ. -- Mike

Yes, the #ifndef USE_48_BIT_KSEG case is strange. Wonder what is going on 
there. Should _pa() not do the same?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
