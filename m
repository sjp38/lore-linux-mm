Message-ID: <40D09872.4090107@colorfullife.com>
Date: Wed, 16 Jun 2004 20:58:58 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: [PATCH]: Option to run cache reap in thread mode
References: <40D08225.6060900@colorfullife.com> <20040616180208.GD6069@sgi.com>
In-Reply-To: <20040616180208.GD6069@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dimitri Sivanich <sivanich@sgi.com>
Cc: linux-kernel@vger.kernel.org, lse-tech <lse-tech@lists.sourceforge.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dimitri Sivanich wrote:

>>Do you use the default batchcount values or have you increased the values?
>>    
>>
>
>Default.
>
>  
>
Could you try to reduce them? Something like (as root)

# cd /proc
# cat slabinfo | gawk '{printf("echo \"%s %d %d %d\" > 
/proc/slabinfo\n", $1,$9,4,2);}' | bash

If this doesn't help then perhaps the timer should run more frequently 
and scan only a part of the list of slab caches.

--
    Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
