Message-ID: <465178E6.60305@users.sourceforge.net>
From: Andrea Righi <righiandr@users.sourceforge.net>
Reply-To: righiandr@users.sourceforge.net
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] log out-of-virtual-memory events
References: <E1Hp5RZ-0001CF-00@calista.eckenfels.net>	<464ED292.8020202@users.sourceforge.net> <20070520203209.ec952a84.akpm@linux-foundation.org>
In-Reply-To: <20070520203209.ec952a84.akpm@linux-foundation.org>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Date: Mon, 21 May 2007 12:48:33 +0200 (MEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Bernd Eckenfels <ecki@lina.inka.de>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Sat, 19 May 2007 12:34:01 +0200 (MEST) Andrea Righi <righiandr@users.sourceforge.net> wrote:
> 
>> Print informations about userspace processes that fail to allocate new virtual
>> memory.
> 
> Why is this useful?
> 

Well... in strict overcommit mode (overcommit_memory=2) this is the only way to
track down problems of the (bad-designed) user applications that exit when they
receive a -ENOMEM without logging anything... and, anyway, it could be an
additional aid in figuring out what is going wrong on inside a system. BTW, I
don't think it should be enabled by default, so this is the reason why it should
depend on print_fatal_signals patch.

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
