From: Andi Kleen <ak@suse.de>
Subject: Re: [rfc][patch] mm: scalable vmaps
Date: Mon, 18 Feb 2008 11:20:20 +0100
References: <20080218082219.GA2018@wotan.suse.de> <47B94FF7.3030200@goop.org>
In-Reply-To: <47B94FF7.3030200@goop.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200802181120.20722.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Nick Piggin <npiggin@suse.de>, David Chinner <dgc@sgi.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Assuming that aliased pages are relatively rare, then its OK for this 
> function to be heavyweight if it can exit quickly in the non-aliased 
> case (or there's some other cheap way to tell if a page has aliases).  

In theory one could use a new struct page flags bit for that purpose.
On problem is though that they're already rare on 32bit
(although I still think we should just get rid of the flags->zone encoding;
then there would be plenty again) 

And the other problem is that a single bit would directly only work for a single 
remapping. What would you do if there are multiple remaps of the same
page though? I guess for this case you would need to put a reference
count into some separate data structure and make vunmap (or however
it's called now) search it. Could be ugly.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
