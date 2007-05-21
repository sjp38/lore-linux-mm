Date: Sun, 20 May 2007 20:32:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] log out-of-virtual-memory events (was: [RFC] log
 out-of-virtual-memory events)
Message-Id: <20070520203209.ec952a84.akpm@linux-foundation.org>
In-Reply-To: <464ED292.8020202@users.sourceforge.net>
References: <E1Hp5RZ-0001CF-00@calista.eckenfels.net>
	<464ED292.8020202@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: righiandr@users.sourceforge.net
Cc: Bernd Eckenfels <ecki@lina.inka.de>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Sat, 19 May 2007 12:34:01 +0200 (MEST) Andrea Righi <righiandr@users.sourceforge.net> wrote:

> Print informations about userspace processes that fail to allocate new virtual
> memory.

Why is this useful?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
