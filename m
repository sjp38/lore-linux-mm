Date: Tue, 15 Jan 2008 20:42:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] Converting writeback linked lists to a tree based data
 structure
Message-Id: <20080115204236.6349ac48.akpm@linux-foundation.org>
In-Reply-To: <400457571.32162@ustc.edu.cn>
References: <20080115080921.70E3810653@localhost>
	<1200386774.15103.20.camel@twins>
	<532480950801150953g5a25f041ge1ad4eeb1b9bc04b@mail.gmail.com>
	<400452490.28636@ustc.edu.cn>
	<20080115194415.64ba95f2.akpm@linux-foundation.org>
	<400457571.32162@ustc.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Fengguang Wu <wfg@mail.ustc.edu.cn>
Cc: Michael Rubin <mrubin@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 16 Jan 2008 12:25:53 +0800 Fengguang Wu <wfg@mail.ustc.edu.cn> wrote:

> list_heads are OK if we use them for one and only function.

Not really.  They're inappropriate when you wish to remember your
position in the list while you dropped the lock (as we must do in
writeback).

A data structure which permits us to interate across the search key rather
than across the actual storage locations is more appropriate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
