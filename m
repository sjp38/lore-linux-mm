Date: Mon, 24 Nov 2003 14:55:27 -0800
From: Mike Fedyk <mfedyk@matchmail.com>
Subject: OOps! was: 2.6.0-test9-mm5
Message-ID: <20031124225527.GB1343@mis-mike-wstn.matchmail.com>
References: <20031121121116.61db0160.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20031121121116.61db0160.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm getting an oops on boot, right after serial is initialised.

Two things it says:
BAD EIP!
Trying to kill init!

Yes, I'm using preempt.  I'll try without, and see if that "fixes" the
problem, and try some other versions, since the last 2.6 booted on this
machine is 2.6.0-test6-mm4.

Mike
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
