Received: from lin.varel.bg (root@lin.varel.bg [212.50.6.9])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA03906
	for <linux-mm@kvack.org>; Mon, 16 Nov 1998 11:50:31 -0500
Message-ID: <365057C8.50B31465@varel.bg>
Date: Mon, 16 Nov 1998 18:50:16 +0200
From: Petko Manolov <petkan@varel.bg>
MIME-Version: 1.0
Subject: Re: 4M kernel pages
References: <Pine.LNX.3.96.981113150452.4593A-100000@mirkwood.dummy.home> <364FE29E.2CF14EEA@varel.bg> <wd8emr3yfeu.fsf@parate.irisa.fr> <36503F86.FC08594@varel.bg> <wd8zp9rwtc7.fsf@parate.irisa.fr>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "David Mentr\\'e" <David.Mentre@irisa.fr>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Mentr\'e wrote:
> 
> Not exactly. 4MB pages for kernel are setted up _before_ the kernel is
> started.
> Look at arch/i386/kernel/head.S:

This is only for SMP machines.

> To be honest, I'm not sure that this is done here, but I'm *sure* that
> kernel uses 4Mb pages.

;-) I got sure by other way. In kernel mode i red the whole page
directory. All kernel page dir entries ended with LSB == 0xe3.
7th bit on means 4M pages. 1 and 0 bits means respectively r/w and
present.
The point is that 6th bit is also 1 when it supposed to be 0
acording to Intel docs.


Excuse me all for this boring mails!


regards
-- 
Petko Manolov - petkan@varel.bg
http://www.varel.bg/~petkan
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
