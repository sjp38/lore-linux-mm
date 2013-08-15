Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 145476B0085
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 19:20:50 -0400 (EDT)
Date: Thu, 15 Aug 2013 16:22:26 -0700
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC PATCH] Fix aio performance regression for database caused
 by THP
Message-ID: <20130815232226.GA5661@kroah.com>
References: <1376590389.24607.33.camel@concerto>
 <20130815141616.6cf60a354b9a92214ac0c246@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130815141616.6cf60a354b9a92214ac0c246@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Khalid Aziz <khalid.aziz@oracle.com>, aarcange@redhat.com, hannes@cmpxchg.org, mgorman@suse.de, riel@redhat.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Thu, Aug 15, 2013 at 02:16:16PM -0700, Andrew Morton wrote:
> I tagged this for a -stable backport.  To allow time for review and
> testing I'll plan to merge the patch into 3.12-rc1, so it should
> materialize in 3.11.x (and hopefully earlier) stable kernels after that.
> 
> To facilitate backporting the patch could have been quite a bit
> smaller, with some simple restructuring.  It applies OK to 3.10, but
> not 3.9.  Hopefully that's good enough...

3.9 is end-of-life, and I do not know anyone who is wishing to try to
keep it going, so don't worry about it anymore.  3.10 is great to have
if possible.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
