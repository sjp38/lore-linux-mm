Date: Sun, 31 Aug 2003 11:44:32 -0400 (EDT)
From: Zwane Mwaikambo <zwane@linuxpower.ca>
Subject: Re: 2.6.0-test4-mm4
In-Reply-To: <Pine.LNX.4.44.0308310926120.26483-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.53.0308311142550.16584@montezuma.fsmlabs.com>
References: <Pine.LNX.4.44.0308310926120.26483-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thomas Molina <tmolina@cablespeed.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 31 Aug 2003, Thomas Molina wrote:

> Thank you Adrew.  I have been following a panic in store_stackinfo since 
> it was introduced with CONFIG_DEBUG_PAGEALLOC (see bugzilla #973).  
> 2.6.0-test4-mm4 was the first kernel version I have tested which didn't 
> exhibit this failure mode.  
> 
> I do get a hang on boot in RedHat 8 if all the other "kernel hacking" 
> options are enabled.  This hang comes at the point in the boot sequence 
> where the next message I would expect is the mounting of /proc.  I've not 
> looked into it too deeply since it sounded similar to what others have 
> seen, and it wasn't my main focus.  I'll go back later and look into it if 
> the condition persists.

Well you appeared to have serio problems and there have been a number of 
changes in the input department. Do you know which kernel hacking option 
causes the new hang?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
