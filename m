Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 71BF76B00B8
	for <linux-mm@kvack.org>; Fri,  7 Jan 2011 12:18:43 -0500 (EST)
Date: Fri, 7 Jan 2011 09:18:34 -0800
From: Randy Dunlap <randy.dunlap@Oracle.com>
Subject: Re: mmotm 2011-01-06-15-41 uploaded (apple_bl)
Message-Id: <20110107091834.47786e35.randy.dunlap@oracle.com>
In-Reply-To: <201101070014.p070Egpo023959@imap1.linux-foundation.org>
References: <201101070014.p070Egpo023959@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, mjg@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 06 Jan 2011 15:41:14 -0800 akpm@linux-foundation.org wrote:

> The mm-of-the-moment snapshot 2011-01-06-15-41 has been uploaded to
> 
>    http://userweb.kernel.org/~akpm/mmotm/
> 
> and will soon be available at
> 
>    git://zen-kernel.org/kernel/mmotm.git
> 
> It contains the following patches against 2.6.37:


When ACPI is not enabled:

drivers/video/backlight/apple_bl.c:142: warning: 'struct acpi_device' declared inside parameter list
drivers/video/backlight/apple_bl.c:142: warning: its scope is only this definition or declaration, which is probably not what you want
drivers/video/backlight/apple_bl.c:200: warning: 'struct acpi_device' declared inside parameter list
drivers/video/backlight/apple_bl.c:214: error: variable 'apple_bl_driver' has initializer but incomplete type
drivers/video/backlight/apple_bl.c:215: error: unknown field 'name' specified in initializer
drivers/video/backlight/apple_bl.c:215: warning: excess elements in struct initializer
drivers/video/backlight/apple_bl.c:215: warning: (near initialization for 'apple_bl_driver')
drivers/video/backlight/apple_bl.c:216: error: unknown field 'ids' specified in initializer
drivers/video/backlight/apple_bl.c:216: warning: excess elements in struct initializer
drivers/video/backlight/apple_bl.c:216: warning: (near initialization for 'apple_bl_driver')
drivers/video/backlight/apple_bl.c:217: error: unknown field 'ops' specified in initializer
drivers/video/backlight/apple_bl.c:217: error: extra brace group at end of initializer
drivers/video/backlight/apple_bl.c:217: error: (near initialization for 'apple_bl_driver')
drivers/video/backlight/apple_bl.c:220: warning: excess elements in struct initializer
drivers/video/backlight/apple_bl.c:220: warning: (near initialization for 'apple_bl_driver')
drivers/video/backlight/apple_bl.c: In function 'apple_bl_init':
drivers/video/backlight/apple_bl.c:225: error: implicit declaration of function 'acpi_bus_register_driver'
drivers/video/backlight/apple_bl.c: In function 'apple_bl_exit':
drivers/video/backlight/apple_bl.c:230: error: implicit declaration of function 'acpi_bus_unregister_driver'


Should BACKLIGHT_APPLE also depend on ACPI?


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
