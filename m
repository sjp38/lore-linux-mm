Date: Thu, 07 Aug 2003 11:30:48 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 2.6.0-test2-mm5
Message-ID: <37150000.1060281047@[10.10.2.4]>
In-Reply-To: <3F321115.80606@cyberone.com.au>
References: <20030806223716.26af3255.akpm@osdl.org>	<28050000.1060237907@[10.10.2.4]> <20030807000542.5cbf0a56.akpm@osdl.org> <3F320DFC.6070400@cyberone.com.au> <3F32108A.2010000@cyberone.com.au> <3F321115.80606@cyberone.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> Andrew and or Martin, please test attached patch.
>> Thanks.
>> 
> 
> Well, one of the WARN conditions I put in there is clearly
> redundant...

Yeah, that patch fixes it.

Thanks,

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
