Date: Mon, 11 Jul 2005 19:55:40 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [Fwd: [PATCH 2/4] cpusets new __GFP_HARDWALL flag]
Message-Id: <20050711195540.681182d0.pj@sgi.com>
In-Reply-To: <42D2AE0F.8020809@austin.ibm.com>
References: <1121101013.15095.19.camel@localhost>
	<42D2AE0F.8020809@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joel Schopp <jschopp@austin.ibm.com>
Cc: haveblue@us.ibm.com, linux-mm@kvack.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

Joel wrote:
> I wouldn't mind  changing __GFP_USERRCLM to __GFP_USERALLOC
> or some neutral name we could share.

A neutral term would be good.  Since you are ahead of me (being
already in Andrew's tree, while I just made my first linux-mm post),
I figure that means you get to pick the name.  Unless it is seriously
defective for my purposes, I will just accept what is.

Dave wrote:
> The nice part about using __GFP_USER as the name is that it describes
> how it's going to be used rather than how the kernel is going to treat
> it.

Yup - agreed.  Though, in real life, that's hidden beneath the (no
underscore) GFP_USER flag, so it's only a few kernel memory hackers
we will be confusing, not the horde of driver writers.

One question.  I've not actually read the memory fragmentation
avoidance patch, so this might be a stupid question.  That
notwithstanding, do you really need two flags, one KERN and one USER?
Or would one flag be sufficient - to mark USER pages.  Unmarked pages
would be KERN, presumably.  One really only needs 2 bits if one has
3 or 4 states to track -- if that's the case, it's not clear to me
what those 3 or 4 states are (maybe if I actually read the patch it
would be clear ;).

I intended to CC Mel on the original post -- but then forgot to.
Thanks for passing it along to him, Dave.


-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
