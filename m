Subject: Re: Please test: workaround to help swapoff behaviour
Message-ID: <OF083B7070.89B5A2B7-ON85256A67.004AD50A@pok.ibm.com>
From: "Bulent Abali" <abali@us.ibm.com>
Date: Sun, 10 Jun 2001 09:56:04 -0400
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Mike Galbraith <mikeg@wen-online.de>, Derek Glidden <dglidden@illusionary.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>


>The fix is to kill the dead/orphaned swap pages before we get to
>swapoff.  At shutdown time there is practically nothing active in
> ...
>Once the dead swap pages problem is fixed it is time to optimize
>swapoff.

I think fixing the orphaned swap pages problem will eliminate the
problem all together.  Probably there is no need to optimize
swapoff.

Because as the system is shutting down all the processes will be
killed and their pages in swap will be orphaned. If those pages
were to be reaped in a timely manner there wouldn't be any work
left for swapoff.

Bulent


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
