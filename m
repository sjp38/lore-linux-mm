Date: Mon, 28 Jul 2008 12:44:37 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: GRU driver feedback
Message-ID: <20080728174437.GA29795@sgi.com>
References: <20080723141229.GB13247@wotan.suse.de> <20080728173605.GB28480@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080728173605.GB28480@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Whoops:

>
> - In gru_fault, I don't think you've validated the size of the vma, and it
>   definitely seems like you haven't taken offset into the vma into account
>   either. remap_pfn_range etc should probably validate the former because I'm
>   sure this isn't the only driver that might get it wrong. The latter can't
>   really be detected though. Please fix or make it more obviously correct (eg
>   a comment).

ZZZ
s/ZZZ/fixed/



--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
