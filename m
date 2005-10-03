Subject: Re: [PATCH]: Clean up of __alloc_pages
From: Rohit Seth <rohit.seth@intel.com>
In-Reply-To: <433F4F67.4090800@yahoo.com.au>
References: <20051001120023.A10250@unix-os.sc.intel.com>
	 <433F4F67.4090800@yahoo.com.au>
Content-Type: text/plain
Date: Mon, 03 Oct 2005 09:50:01 -0700
Message-Id: <1128358201.8472.7.camel@akash.sc.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 2005-10-02 at 13:09 +1000, Nick Piggin wrote:

> Perhaps splitting it into 2 would be a good idea - ie. first
> patch does the cleanup, second does the direct pcp list alloc.
> 
> Regarding the direct pcp list allocation - I think it is a good
> idea, because we're currently already accounting pcp list pages
> as being 'allocated' for the purposes of the reclaim watermarks.
> 

Right.  

> Also, the structure is there to avoid touching cachelines whenever
> possible so it makes sense to use it early here. Do you have any
> performance numbers or allocation statistics (e.g. %pcp hits) to
> show?
> 

No, I don't have any data at this point to share.

> Also, I would really think about uninlining get_page_from_freelist,
> and inlining buffered_rmqueue, so that the constant 'replenish'
> argument can be propogated into buffered_rmqueue and should allow
> for some nice optimisations. While not bloating the code too much
> because your get_page_from_freelist becomes out of line.

I will do that.

Thanks for your feedback,
-rohit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
