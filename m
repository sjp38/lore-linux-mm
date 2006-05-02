Message-ID: <4456D85E.6020403@yahoo.com.au>
Date: Tue, 02 May 2006 13:56:14 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 00/14] remap_file_pages protection support
References: <20060430172953.409399000@zion.home.lan> <4456D5ED.2040202@yahoo.com.au>
In-Reply-To: <4456D5ED.2040202@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: blaisorblade@yahoo.it
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> blaisorblade@yahoo.it wrote:
> 
>> The first idea is to use this for UML - it must create a lot of single 
>> page
>> mappings, and managing them through separate VMAs is slow.

[...]

> Let's try get back to the good old days when people actually reported
> their bugs (togther will *real* numbers) to the mailing lists. That way,
> everybody gets to think about and discuss the problem.

Speaking of which, let's see some numbers for UML -- performance
and memory. I don't doubt your claims, but I (and others) would be
interested to see.

Thanks

PS. I'll be away for the next few days.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
