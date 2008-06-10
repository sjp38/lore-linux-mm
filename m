From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: 2.6.26-rc5-mm2
Date: Tue, 10 Jun 2008 16:12:14 +1000
References: <20080609223145.5c9a2878.akpm@linux-foundation.org>
In-Reply-To: <20080609223145.5c9a2878.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200806101612.15041.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 10 June 2008 15:31, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.26-rc5/2.
>6.26-rc5-mm2/
>
> - This is a bugfixed version of 2.6.26-rc5-mm1 - mainly to repair a
>   vmscan.c bug which would have prevented testing of the other vmscan.c
>   bugs^Wchanges.

BTW. this is known to be broken with x86 1GB pages and direct-IO, due
to interaction between huge pages patchset and lockless get_user_pages.

My fault. I was away from the screen over the long weekend here, and
didn't give Andrew the heads-up in time.

This isn't going to be a problem unless you explicitly enable GB pages
and run direct IO (or splice) into or out of them. I can give a fixup
patch to anyone interested in doing so.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
