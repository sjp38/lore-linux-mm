Date: Thu, 13 Jan 2005 16:56:27 +0800
From: Bernard Blackham <bernard@blackham.com.au>
Subject: Re: Odd kswapd behaviour after suspending in 2.6.11-rc1
Message-ID: <20050113085626.GA5374@blackham.com.au>
References: <20050113061401.GA7404@blackham.com.au> <41E61479.5040704@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41E61479.5040704@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 13, 2005 at 05:26:01PM +1100, Nick Piggin wrote:
> >I reverted the changes to mm/vmscan.c between 2.6.10 and 2.6.11-rc1
> >with the attached patch (applies forwards over the top of
> >2.6.11-rc1), and I no longer get any kswapd weirdness.  Is there
> >something in here misbehaving?
> 
> Hmm, it is likely to be the higher order watermarks change.
> 
> Can you get a couple of Alt+SysRq+M traces during the time when
> kswapd is going crazy please?

Embarrasingly, I can't reproduce it at the moment. It was previously
occuring on every single suspend. Wondering if it's linked with swap
usage - I'll keep watching and provide some traces when it happens
again.

Thanks,

Bernard.

-- 
 Bernard Blackham <bernard at blackham dot com dot au>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
