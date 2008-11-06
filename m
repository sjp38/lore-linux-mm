Date: Thu, 6 Nov 2008 11:02:34 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/2] vmap: cope with vm_unmap_aliases before
	vmalloc_init()
Message-ID: <20081106100234.GM4890@elte.hu>
References: <49010D41.1080305@goop.org> <200810281619.10388.nickpiggin@yahoo.com.au> <4906CBCA.6060908@goop.org> <4911EB5C.4030901@goop.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4911EB5C.4030901@goop.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* Jeremy Fitzhardinge <jeremy@goop.org> wrote:

> Jeremy Fitzhardinge wrote:
>> Xen can end up calling vm_unmap_aliases() before vmalloc_init() has
>> been called.  In this case its safe to make it a simple no-op.
>>
>> Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
>
> Ping?  Nick, Ingo: do you want to pick these up, or shall I send them to  
> Linus myself?

i've applied them to tip/core/urgent and will send them to Linus 
unless Nick or Andrew has objections.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
