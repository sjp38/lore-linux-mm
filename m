Date: Fri, 17 Oct 2003 11:19:55 -0700
From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: 2.6.0-test7-mm1 4G/4G hanging at boot
Message-Id: <20031017111955.439d01c8.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.kernel.org>
Cc: mingo@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm seeing this at boot:

Checking if this processor honours the WP bit even in supervisor mode...

then I wait for 1-2 minutes and hit the power button.
This is on an IBM dual-proc P4 (non-HT) with 1 GB of RAM.

Has anyone else seen this?  Suggestions or fixes?

Thanks,
--
~Randy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
