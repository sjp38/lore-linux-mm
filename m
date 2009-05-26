Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1E5B56B005C
	for <linux-mm@kvack.org>; Tue, 26 May 2009 09:12:02 -0400 (EDT)
Date: Tue, 26 May 2009 15:18:38 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [7/16] POISON: Add basic support for poisoned pages in fault handler
Message-ID: <20090526131838.GE846@one.firstfloor.org>
References: <20090407509.382219156@firstfloor.org> <20090407151004.2F5D21D0470@basil.firstfloor.org> <4A1BE6BE.90209@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A1BE6BE.90209@hitachi.com>
Sender: owner-linux-mm@kvack.org
To: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>, Taketoshi Sakuraba <taketoshi.sakuraba.hc@hitachi.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 26, 2009 at 09:55:26PM +0900, Hidehiro Kawai wrote:
> > +			print_bad_pte(vma, address, pte, NULL);
> > +			ret = VM_FAULT_OOM;
> > +		}
> >  		goto out;
> >  	}
> >  	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
> > @@ -2451,6 +2459,9 @@
> >  		/* Had to read the page from swap area: Major fault */
> >  		ret = VM_FAULT_MAJOR;
> >  		count_vm_event(PGMAJFAULT);
> > +	} else if (PagePoison(page)) {
> > +		ret = VM_FAULT_POISON;
> 
> delayacct_clear_flag(DELAYACCT_PF_SWAPIN) would be needed here.

Thanks for the review. Added.

Must have been a forward port error, I could swear that wasn't there
yet when I wrote this originally :)

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
