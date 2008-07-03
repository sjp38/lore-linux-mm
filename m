Message-ID: <486CC533.6080302@buttersideup.com>
Date: Thu, 03 Jul 2008 13:25:23 +0100
From: Tim Small <tim@buttersideup.com>
MIME-Version: 1.0
Subject: Failing memory auto-hotremove support?
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: bluesmoke-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

I just noticed that there is memory hotplug / hotremove support in the 
kernel.org kernel now.

I was thinking that it may be desirable (e.g. on large NUMA systems) to 
automatically trigger the removal of memory modules (or just take a 
section of the memory module out of use, if applicable), if a memory 
module exceeded a pre-set correctable error rate (or RIGHT-NOW, if an 
uncorrectable memory error was detected).

Tim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
