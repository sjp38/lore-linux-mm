Date: Tue, 21 May 2002 14:47:59 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: [RFC][PATCH] using page aging to shrink caches
Message-ID: <20020521144759.B1153@redhat.com>
References: <200205180010.51382.tomlins@cam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200205180010.51382.tomlins@cam.org>; from tomlins@cam.org on Sat, May 18, 2002 at 12:10:51AM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, May 18, 2002 at 12:10:51AM -0400, Ed Tomlinson wrote:
> I have never been happy with the way slab cache shrinking worked.  This is an
> attempt to make it better.  Working with the rmap vm on pre7-ac2, I have done
> the following.

Thank you!  This is should help greatly with some of the vm imbalances by 
making slab reclaim part of the self tuning dynamics instead of hard coded 
magic numbers.  Do you have any plans to port this patch to 2.5 for inclusion?  
It would be useful to get testing in the 2.5 before merging in 2.4.

		-ben
-- 
"You will be reincarnated as a toad; and you will be much happier."
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
