Message-ID: <40C5E9D5.6080202@ammasso.com>
Date: Tue, 08 Jun 2004 11:31:17 -0500
From: Timur Tabi <timur.tabi@ammasso.com>
MIME-Version: 1.0
Subject: Re: What happened to try_to_swap_out()?
References: <Pine.LNX.4.44.0406081224590.23676-100000@chimarrao.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.44.0406081224590.23676-100000@chimarrao.boston.redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:

> Looks like the bug is in your driver, not the VM.
> 
> The VMA that maps such pages should be set VM_RESERVED
> (or whatever the name of that flag was)

I called map_user_kiobuf to get the pages.  Shouldn't that be enough?

>>Also, I noticed that RedHat 9.0 doesn't have try_to_swap_out() either. 
>>I guess they ported some 2.6 code to 2.4.  Can anyone corroborate that?
> 
> Yes.

Is there a name for the patch they applied to 2.4 to make it look like 2.6?

-- 
Timur Tabi
Staff Software Engineer
timur.tabi@ammasso.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
