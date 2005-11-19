Date: Fri, 18 Nov 2005 16:21:12 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC][PATCH 2/8] Create emergency trigger
Message-Id: <20051118162112.7bf21df5.pj@sgi.com>
In-Reply-To: <437E2D57.9050304@us.ibm.com>
References: <437E2C69.4000708@us.ibm.com>
	<437E2D57.9050304@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> @@ -876,6 +879,16 @@ __alloc_pages(gfp_t gfp_mask, unsigned i
>  	int can_try_harder;
>  	int did_some_progress;
>  
> +	if (is_emergency_alloc(gfp_mask)) {

Can this check for is_emergency_alloc be moved lower in __alloc_pages?

I don't see any reason why most __alloc_pages() calls, that succeed
easily in the first loop over the zonelist, have to make this check.
This would save one conditional test and jump on the most heavily
used code path in __alloc_pages().

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
