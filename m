Date: Thu, 27 Apr 2006 13:44:42 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 1/2 (repost)] mm: serialize OOM kill operations
Message-Id: <20060427134442.639a6d19.pj@sgi.com>
In-Reply-To: <200604271308.10080.dsp@llnl.gov>
References: <200604271308.10080.dsp@llnl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Peterson <dsp@llnl.gov>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@surriel.com, nickpiggin@yahoo.com.au, ak@suse.de, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Dave wrote:
> @@ -350,6 +353,8 @@ struct mm_struct {
>  	/* aio bits */
>  	rwlock_t		ioctx_list_lock;
>  	struct kioctx		*ioctx_list;
> +
> +	unsigned long flags;

I see Andi didn't reply to your question concerning what
struct he saw a 'flags' in.

Adding a flags word still costs a slot in mm_struct.

Adding a 'oom_notify' bitfield after the existing 'dumpable'
bitfield in mm_struct would save that slot:

        unsigned dumpable:2;
	unsigned oom_notify:1;

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
