Subject: Re: Break 2.4 VM in five easy steps
References: <3B1E4CD0.D16F58A8@illusionary.com>
	<3b204fe5.4014698@mail.mbay.net> <3B1E5316.F4B10172@illusionary.com>
	<m1wv6p5uqp.fsf@frodo.biederman.org>
	<3B1E7ABA.EECCBFE0@illusionary.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 06 Jun 2001 12:52:07 -0600
In-Reply-To: <3B1E7ABA.EECCBFE0@illusionary.com>
Message-ID: <m1ofs15tm0.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Derek Glidden <dglidden@illusionary.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Derek Glidden <dglidden@illusionary.com> writes:


> The problem I reported is not that 2.4 uses huge amounts of swap but
> that trying to recover that swap off of disk under 2.4 can leave the
> machine in an entirely unresponsive state, while 2.2 handles identical
> situations gracefully.  
> 

The interesting thing from other reports is that it appears to be kswapd
using up CPU resources.  Not the swapout code at all.  So it appears
to be a fundamental VM issue.  And calling swapoff is just a good way
to trigger it. 

If you could confirm this by calling swapoff sometime other than at
reboot time.  That might help.  Say by running top on the console.

Eric



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
