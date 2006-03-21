Message-ID: <441FEFBB.9000709@yahoo.com.au>
Date: Tue, 21 Mar 2006 23:21:15 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH][3/8] mm: get_user_pages interface change
References: <bc56f2f0603200537g35d2bfd5m@mail.gmail.com>
In-Reply-To: <bc56f2f0603200537g35d2bfd5m@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stone Wang <pwstone@gmail.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stone Wang wrote:
> Adjust references of get_user_pages.
> 

You typically do this in the same step as you adjust
get_user_pages itself.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
