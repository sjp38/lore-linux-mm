Date: Tue, 16 Jan 2007 11:05:18 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 6/29] Tweak IA64 arch dependent files to work with PTI
In-Reply-To: <20070113024611.29682.41796.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Message-ID: <Pine.LNX.4.64.0701161104330.6637@schroedinger.engr.sgi.com>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
 <20070113024611.29682.41796.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Davies <pauld@gelato.unsw.edu.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 13 Jan 2007, Paul Davies wrote:

>  	 * We may get interrupts here, but that's OK because interrupt
>  	 * handlers cannot touch user-space.
>  	 */
> -	ia64_set_kr(IA64_KR_PT_BASE, __pa(next->pgd));
> +	ia64_set_kr(IA64_KR_PT_BASE, __pa(next->page_table.pgd));
>  	activate_context(next);

Argh... The requirement for patches is that the kernel compiles after each 
patch was required. It looks as if the last patch broke the compile.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
