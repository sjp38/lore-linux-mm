Message-ID: <3F155536.8090608@aitel.hist.no>
Date: Wed, 16 Jul 2003 15:37:58 +0200
From: Helge Hafting <helgehaf@aitel.hist.no>
MIME-Version: 1.0
Subject: Re: 2.6.0-test1-mm1
References: <6uwueidhdd.fsf@zork.zork.net> <Pine.LNX.4.44.0307161052310.6193-100000@localhost.localdomain> <20030716101949.GE2684@wind.cocodriloo.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Antonio Vargas <wind@cocodriloo.com>
Cc: Ingo Molnar <mingo@elte.hu>, Sean Neakums <sneakums@zork.net>, Andrew Morton <akpm@osdl.org>, Con Kolivas <kernel@kolivas.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Antonio Vargas wrote:
[...]
> It always happened to me when I run "make menuconfig" under gnome-terminal on
> redhat 9 with 2.5.73. Is it because of busy-waiting on a variable shared
> amongst multiple processes/threads? If so, it smells of a bug in the application,
> busy-waiting is _BAD_.

Ouch.  Well, it is good that scheduler changes made the bug visible,
so it can be fixed.  Certainly no reason to
work around it in the kernel, the effort is better spent on fixing
the bug.  Distributors can make sure they have fixed their apps
before distributing 2.6.

Helge Hafting

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
