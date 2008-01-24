Date: Thu, 24 Jan 2008 14:20:05 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/2]: MM: Make Paget Tables Relocatable--Conditional  TLB Flush
In-Reply-To: <20080123161340.A1AAEDCA00@localhost>
References: <20080123161340.A1AAEDCA00@localhost>
Message-Id: <20080124140913.5FFE.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ross Biro <rossb@google.com>rossb@google.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello.

This is a nitpick, but all of archtectures code except generic use
MMF_NNED_FLUSH at clear_bit()...
     ^
Please fix misspell.

Bye.

> 
> diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/alpha/kernel/smp.c 2.6.23a/arch/alpha/kernel/smp.c
> --- 2.6.23/arch/alpha/kernel/smp.c	2007-10-09 13:31:38.000000000 -0700
> +++ 2.6.23a/arch/alpha/kernel/smp.c	2007-10-29 13:50:06.000000000 -0700
> @@ -850,6 +850,8 @@ flush_tlb_mm(struct mm_struct *mm)
>  {
>  	preempt_disable();
>  
> +	clear_bit(MMF_NNED_FLUSH, mm->flags);
> +
>  	if (mm == current->active_mm) {
>  		flush_tlb_current(mm);
>  		if (atomic_read(&mm->mm_users) <= 1) {


-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
