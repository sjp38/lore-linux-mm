Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 8FE756B00ED
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 16:29:57 -0500 (EST)
Date: Mon, 20 Feb 2012 22:29:55 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] thp: allow a hwpoisoned head page to be put back to LRU
Message-ID: <20120220212955.GD10222@redhat.com>
References: <20120220211040.8887.22420.email-sent-by-dnelson@aqua>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120220211040.8887.22420.email-sent-by-dnelson@aqua>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dean Nelson <dnelson@redhat.com>
Cc: linux-mm@kvack.org, Jin Dongming <jin.dongming@np.css.fujitsu.com>, linux-kernel@vger.kernel.org

On Mon, Feb 20, 2012 at 04:10:40PM -0500, Dean Nelson wrote:
> Andrea Arcangeli pointed out to me that a check in __memory_failure() which
> was intended to prevent THP tail pages from being checked for the absence
> of the PG_lru flag (something that is always the case), was also preventing
> THP head pages from being checked.
> 
> A THP head page could actually benefit from the call to shake_page() by
> ending up being put back to a LRU, provided it had been waiting in a
> pagevec array.
> 
> Andrea suggested that the "!PageTransCompound(p)" in the if-statement
> should be replaced by a "!PageTransTail(p)", thus allowing THP head pages
> to be checked and possibly shaken.
> 
> Signed-off-by: Dean Nelson <dnelson@redhat.com>

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
