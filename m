Date: Sun, 31 Aug 2003 09:41:23 -0500 (CDT)
From: Thomas Molina <tmolina@cablespeed.com>
Subject: Re: 2.6.0-test4-mm4
In-Reply-To: <20030830161536.7e7be6d3.akpm@osdl.org>
Message-ID: <Pine.LNX.4.44.0308310926120.26483-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, zwane@holomorphy.com
List-ID: <linux-mm.kvack.org>

Thank you Adrew.  I have been following a panic in store_stackinfo since 
it was introduced with CONFIG_DEBUG_PAGEALLOC (see bugzilla #973).  
2.6.0-test4-mm4 was the first kernel version I have tested which didn't 
exhibit this failure mode.  

I do get a hang on boot in RedHat 8 if all the other "kernel hacking" 
options are enabled.  This hang comes at the point in the boot sequence 
where the next message I would expect is the mounting of /proc.  I've not 
looked into it too deeply since it sounded similar to what others have 
seen, and it wasn't my main focus.  I'll go back later and look into it if 
the condition persists.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
