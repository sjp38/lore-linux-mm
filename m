Message-ID: <413DE9D3.6050904@sgi.com>
Date: Tue, 07 Sep 2004 12:03:15 -0500
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: swapping and the value of /proc/sys/vm/swappiness
References: <413CB661.6030303@sgi.com> <cone.1094512172.450816.6110.502@pc.kolivas.org> <20040906162740.54a5d6c9.akpm@osdl.org> <cone.1094513660.210107.6110.502@pc.kolivas.org> <20040907000304.GA8083@logos.cnet> <413D8FB2.1060705@cyberone.com.au>
In-Reply-To: <413D8FB2.1060705@cyberone.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Con Kolivas <kernel@kolivas.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, mbligh@aracnet.com
List-ID: <linux-mm.kvack.org>


Nick Piggin wrote:
> 
> 
> Just a suggestion - I'd look at the thrashing control patch first.
> I bet that's the cause.
> 
> 
The token based thrashing control patch is also in 2.6.8.1-mm4, and that
kernel doesn't behave nearly as badly as 2.5.9-rc1-mm3, so I don't think
that is the culprit in that case.
-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
