Message-ID: <477FDAA8.2030001@hp.com>
Date: Sat, 05 Jan 2008 14:29:44 -0500
From: Mark Seger <Mark.Seger@hp.com>
MIME-Version: 1.0
Subject: Supports for new slab allocator now in latest release
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: util-linux-ng@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

I just wanted to let people know that as a result of a discussion on 
linux-mm I've added support for the new slab allocator to my collectl 
utility, now making it real easy to dynamically monitor allocations 
along with all the other types of monitoring collectl does.  I've also 
put together a webpage at http://collectl.sourceforge.net/SlabInfo.html 
to give a taste of how this all works as well as to show a few different 
types of output.
-mark

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
