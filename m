Message-ID: <413D8FB2.1060705@cyberone.com.au>
Date: Tue, 07 Sep 2004 20:38:42 +1000
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: swapping and the value of /proc/sys/vm/swappiness
References: <413CB661.6030303@sgi.com> <cone.1094512172.450816.6110.502@pc.kolivas.org> <20040906162740.54a5d6c9.akpm@osdl.org> <cone.1094513660.210107.6110.502@pc.kolivas.org> <20040907000304.GA8083@logos.cnet>
In-Reply-To: <20040907000304.GA8083@logos.cnet>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Con Kolivas <kernel@kolivas.org>, Andrew Morton <akpm@osdl.org>, raybry@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, mbligh@aracnet.com
List-ID: <linux-mm.kvack.org>


Marcelo Tosatti wrote:

>
>Hi kernel fellows,
>
>I volunteer. I'll try something tomorrow to compare swappiness of older kernels like  
>2.6.5 and 2.6.6, which were fine on SGI's Altix tests, up to current newer kernels 
>(on small memory boxes of course).
>

Hi Marcelo,

Just a suggestion - I'd look at the thrashing control patch first.
I bet that's the cause.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
