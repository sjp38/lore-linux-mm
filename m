Date: Mon, 18 Sep 2000 17:01:24 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [torriem@cs.byu.edu: VM: do_try_to_free_pages failed in 2.2.17]
In-Reply-To: <20000918113131.J10210@redhat.com>
Message-ID: <Pine.LNX.4.21.0009181659130.2325-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org, Michael L Torrie <torriem@cs.byu.edu>, Andrea Arcangeli <andrea@suse.de>
List-ID: <linux-mm.kvack.org>


On Mon, 18 Sep 2000, Stephen C. Tweedie wrote:

> Hi all,
> 
> Yet another 2.2.17-eats-my-VM report.  Does anyone have proven patches
> other than reverting completely to the old 2.2 VM?  There's been lots
> of discussion and hypothesising but no silver bullets so far.
> 
> --Stephen

Have you read Andrea VM-global patch against 2.2.18pre ? 

I have received 3 or 4 reports of success with them. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
