Message-ID: <411326E0.2020703@yahoo.com.au>
Date: Fri, 06 Aug 2004 16:36:16 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] 3/4: writeout watermarks
References: <41130FB1.5020001@yahoo.com.au>	<41130FD2.5070608@yahoo.com.au>	<41131105.8040108@yahoo.com.au>	<20040805222733.477b3017.akpm@osdl.org>	<41131862.5050000@yahoo.com.au>	<20040805224920.6755198d.akpm@osdl.org>	<4113218F.5050803@yahoo.com.au> <20040805231938.6d87476c.akpm@osdl.org>
In-Reply-To: <20040805231938.6d87476c.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
>> Basically what the above code, is scale the dirty_ratio with the
>> amount of unmapped pages, however it doesn't also scale the
>> dirty_background_ratio (it does after my patch).
> 
> 
> OK, that makes sense.
> 

Ah good - I couldn't understand why you didn't like it, but in retrospect
I wasn't being very clear about what it was supposed to do.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
