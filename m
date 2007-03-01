Message-ID: <45E63B08.7070304@yahoo.com.au>
Date: Thu, 01 Mar 2007 13:31:36 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Remove page flags for software suspend
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com> <200702161156.21496.rjw@sisk.pl> <20070228101403.GA8536@elf.ucw.cz> <Pine.LNX.4.64.0702280724540.16552@schroedinger.engr.sgi.com> <20070228210837.GA4760@ucw.cz>
In-Reply-To: <20070228210837.GA4760@ucw.cz>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Christoph Lameter <clameter@engr.sgi.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Pavel Machek wrote:
> Hi!
> 
> 
>>>I... actually do not like that patch. It adds code... at little or no
>>>benefit.
>>
>>We are looking into saving page flags since we are running out. The two 
>>page flags used by software suspend are rarely needed and should be taken 
>>out of the flags. If you can do it a different way then please do.
> 
> 
> Hmm, can't we just add another word to struct page?

That's what we want to avoid. As soon as we add another word, then
everbody goes crazy using it up and we can never remove it again.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
