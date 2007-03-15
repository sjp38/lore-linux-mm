Message-ID: <45F991E5.1060001@redhat.com>
Date: Thu, 15 Mar 2007 14:35:17 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/filemap.c: unconditionally call mark_page_accessed
References: <Pine.GSO.4.64.0703081612290.1080@cpu102.cs.uwaterloo.ca> <20070312142012.GH30777@atrey.karlin.mff.cuni.cz> <20070312143900.GB6016@wotan.suse.de> <20070312151355.GB23532@duck.suse.cz> <Pine.GSO.4.64.0703121247210.7679@cpu102.cs.uwaterloo.ca> <20070312173500.GF23532@duck.suse.cz> <Pine.GSO.4.64.0703131438580.8193@cpu102.cs.uwaterloo.ca> <20070313185554.GA5105@duck.suse.cz> <Pine.GSO.4.64.0703141218530.28958@cpu102.cs.uwaterloo.ca> <1173905741.8763.36.camel@kleikamp.austin.ibm.com>            <20070314213317.GA22234@rhlx01.hs-esslingen.de> <200703151737.l2FHb81d001600@turing-police.cc.vt.edu>
In-Reply-To: <200703151737.l2FHb81d001600@turing-police.cc.vt.edu>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Andreas Mohr <andi@rhlx01.fht-esslingen.de>, Dave Kleikamp <shaggy@linux.vnet.ibm.com>, Ashif Harji <asharji@cs.uwaterloo.ca>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Valdis.Kletnieks@vt.edu wrote:
> On Wed, 14 Mar 2007 22:33:17 BST, Andreas Mohr said:
> 
>> it'd seem we need some kind of state management here to figure out good
>> intervals of when to call mark_page_accessed() *again* for this page. E.g.
>> despite non-changing access patterns you could still call mark_page_accessed(
> )
>> every 32 calls or so to avoid expiry, but this would need extra helper
>> variables.
> 
> What if you did something like
> 
> 	if (jiffies%32) {...
> 
> (Possibly scaling it so the low-order bits change).  No need to lock it, as
> "right most of the time" is close enough.

Bad idea.  That way you would only count page accesses if the
phase of the moon^Wjiffie is just right.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
