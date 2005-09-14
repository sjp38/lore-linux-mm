Message-ID: <4327EA6B.6090102@colorfullife.com>
Date: Wed, 14 Sep 2005 11:16:27 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: VM balancing issues on 2.6.13: dentry cache not getting shrunk
 enough
References: <20050911105709.GA16369@thunk.org> <20050913084752.GC4474@in.ibm.com> <20050913215932.GA1654338@melbourne.sgi.com> <200509141101.16781.ak@suse.de>
In-Reply-To: <200509141101.16781.ak@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: David Chinner <dgc@sgi.com>, Bharata B Rao <bharata@in.ibm.com>, Theodore Ts'o <tytso@mit.edu>, Dipankar Sarma <dipankar@in.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:

>The slab datastructures are not completely suited for this right now,
>but it could be done by using one more of the list_heads in struct page
>for slab backing pages.
>
>  
>
I agree, I even started prototyping something a year ago, but ran out of 
time.
One tricky point are directory dentries: As far as I see, they are 
pinned and unfreeable if a (freeable) directory entry is in the cache.

--
    Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
