Date: Tue, 20 Jan 2004 19:10:40 -0500
From: Zack Winkles <winkie@linuxfromscratch.org>
Subject: I2C sensors error (Re: 2.6.1-mm5)
Message-Id: <20040120191040.2e1b46a9.winkie@linuxfromscratch.org>
In-Reply-To: <20040120000535.7fb8e683.akpm@osdl.org>
References: <20040120000535.7fb8e683.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Yo,

As usual, I've upgraded to the latest -mm, but to my dismay, my
temperature sensors are no longer reporting sane values.  For example,
my motherboard usually reports about 31C, but now never moves up or down
from 210C.  My CPU, likewise, hovers at 210C, but sometimes moves up or
down in what appears to be units of 11.

I'm positive in the correctness of my /sys value parsing (latest gkrellm
drop with lm_sensors values stuck in), so that's a non-issue.  The
modules I'm using are i2c_viapro and w83781d, and of course their
dependencies.  My logs report no errors from the kernel, or any user
space apps/libs of relevance.

If necessary, I can post my .config and anything else applicable.

Later,
Zack
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
