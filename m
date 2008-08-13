Date: Wed, 13 Aug 2008 17:37:19 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC PATCH for -mm 2/5] related function comment fixes (optional)
In-Reply-To: <1218567778.6360.90.camel@lts-notebook>
References: <20080811160430.945C.KOSAKI.MOTOHIRO@jp.fujitsu.com> <1218567778.6360.90.camel@lts-notebook>
Message-Id: <20080813173639.E776.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> > - * vma->vm_mm->mmap_sem must be held for write.
> > + * @vma:   target vma
> > + * @start: start address
> > + * @end:   end address
> > + * @mlock: 0 indicate munlock, otherwise mlock.
> > + *
> > + * return 0 if successed, otherwse return negative value.
> 
> How about:
> 
> 	return 0 on success, [negative] error number on error.

OK. I'll fix at next post.

Thanks carefully review!



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
