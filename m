Message-ID: <3F320DFC.6070400@cyberone.com.au>
Date: Thu, 07 Aug 2003 18:29:48 +1000
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: 2.6.0-test2-mm5
References: <20030806223716.26af3255.akpm@osdl.org>	<28050000.1060237907@[10.10.2.4]> <20030807000542.5cbf0a56.akpm@osdl.org>
In-Reply-To: <20030807000542.5cbf0a56.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Andrew Morton wrote:

>"Martin J. Bligh" <mbligh@aracnet.com> wrote:
>
>>I get lots of these .... (without 4/4 turned on)
>>
>>  Badness in as_dispatch_request at drivers/block/as-iosched.c:1241
>>
>
>yes, it happens with aic7xxx as well.  Sorry about that.
>
>You'll need to revert 
>
>

Sorry. Worked with the sym53c8xx for me. I'll fix.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
