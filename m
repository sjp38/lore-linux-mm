Message-ID: <41EEA575.9040007@mvista.com>
Date: Wed, 19 Jan 2005 10:22:45 -0800
From: Steve Longerbeam <stevel@mvista.com>
MIME-Version: 1.0
Subject: Re: BUG in shared_policy_replace() ?
References: <Pine.LNX.4.44.0501191221400.4795-100000@localhost.localdomain> <41EE9991.6090606@mvista.com> <20050119174506.GH7445@wotan.suse.de>
In-Reply-To: <20050119174506.GH7445@wotan.suse.de>
Content-Type: multipart/mixed;
 boundary="------------090409010005090609090705"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------090409010005090609090705
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



Andi Kleen wrote:

>>got it, except that there is no "new2 = NULL;" in 2.6.10-mm2!
>>
>>Looks like it was misplaced, because I do see it now in 2.6.10.
>>    
>>
>
>I double checked 2.6.10 and the code also looks correct me,
>working as described by Hugh.
>
>Optimistic locking can be ugly :)
>  
>

yeah, 2.6.10 makes sense to me too. But I'm working in -mm2, and
the new2 = NULL line is missing, hence my initial confusion. Trivial
patch to -mm2 attached. Just want to make sure it has been, or will be,
put back in.

Steve

--------------090409010005090609090705
Content-Type: text/plain;
 name="mempolicy-mm2.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mempolicy-mm2.diff"

--- mm/mempolicy.c.orig	2005-01-19 09:52:47.153910873 -0800
+++ mm/mempolicy.c	2005-01-19 09:53:21.548999628 -0800
@@ -1041,6 +1041,7 @@
 				}
 				n->end = start;
 				sp_insert(sp, new2);
+				new2 = NULL;
 				break;
 			} else
 				n->end = start;

--------------090409010005090609090705--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
