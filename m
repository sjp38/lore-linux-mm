Date: Mon, 9 May 2005 14:26:51 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Fw: [Bug 4520] New: /proc/*/maps fragments too quickly compared
 to
Message-Id: <20050509142651.1d3ae91e.akpm@osdl.org>
In-Reply-To: <17023.26119.111329.865429@gargle.gargle.HOWL>
References: <17023.26119.111329.865429@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Wolfgang Wander <wwc@rentec.com>
Cc: mingo@elte.hu, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Wolfgang Wander <wwc@rentec.com> wrote:
>
>    I'm resending this message since I haven't got any response other
> than from another affected user (who was helped by the patch).

It hasn't been forgotten.  I'd prefer to not release 2.6.12 until we've
resolved this.

>    Can you please take a short glimpse and tell me what I need to 
> do to get something like it accepted?

Keep sending emails ;)

Possibly for the 2.6.12 release the safest approach would be to just
disable the free area cache while we think about it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
