Message-ID: <20050201082001.43454.qmail@web51102.mail.yahoo.com>
Date: Tue, 1 Feb 2005 00:20:01 -0800 (PST)
From: baswaraj kasture <kbaswaraj@yahoo.com>
Subject: Kernel 2.4.21 hangs up
In-Reply-To: <41FF0281.6090903@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@muc.de>, Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

Hi,

I compiled kernel 2.4.21 with intel compiler .
While booting it hangs-up . further i found that it
hangsup due to call to "calibrate_delay" routine in
"init/main.c". Also found that loop in the
callibrate_delay" routine goes infinite.When i comment
out the call to "callibrate_delay" routine, it works
fine.Even compiling "init/main.c" with "-O0" works
fine. I am using IA-64 (Intel Itanium 2 ) with EL3.0.

Any pointers will be great help.


Thanks,
-Baswaraj


		
__________________________________ 
Do you Yahoo!? 
Yahoo! Mail - 250MB free storage. Do more. Manage less. 
http://info.mail.yahoo.com/mail_250
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
