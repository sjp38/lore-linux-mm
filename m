Subject: Re: 2.5.70-mm4
From: Paul Larson <plars@linuxtestproject.org>
In-Reply-To: <20030603231827.0e635332.akpm@digeo.com>
References: <20030603231827.0e635332.akpm@digeo.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 04 Jun 2003 10:33:40 -0500
Message-Id: <1054740832.8244.159.camel@plars>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2003-06-04 at 01:18, Andrew Morton wrote:

> . A patch which adds the statfs64() syscall.  This involved some mangling
>   of the BSD accountig code.  If anyone knows how to test BSD accounting,
>   please do so, or let me know.
For what it's worth, LTP has two BSD acct tests and they both pass
fine.  These are not elaborate or stressful in anyway, but they make for
a good, quick sniff test.

Thanks,
Paul Larson


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
