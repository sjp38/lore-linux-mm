Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 890486B0096
	for <linux-mm@kvack.org>; Sat,  7 Mar 2009 17:16:43 -0500 (EST)
Date: Sat, 7 Mar 2009 14:16:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-Id: <20090307141607.0f690427.akpm@linux-foundation.org>
In-Reply-To: <20090307220055.6f79beb8@mjolnir.ossman.eu>
References: <bug-12832-27@http.bugzilla.kernel.org/>
	<20090307122452.bf43fbe4.akpm@linux-foundation.org>
	<20090307220055.6f79beb8@mjolnir.ossman.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pierre Ossman <drzeus@drzeus.cx>
Cc: bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Now another possibility is that someone is gobbling lots of memory
during initcalls.

So here's an untested addition to the `initcall_debug' boot option
which should permit us to work out how much memory each initcall
consumed:

--- a/init/main.c~a
+++ a/init/main.c
@@ -714,6 +714,7 @@ static void __init do_one_initcall(initc
 		print_fn_descriptor_symbol("initcall %s", fn);
 		printk(" returned %d after %Ld msecs\n", result,
 			(unsigned long long) delta.tv64 >> 20);
+		printk("remaining memory: %d\n", nr_free_buffer_pages());
 	}
 
 	msgbuf[0] = 0;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
