From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <E17oYth-0006wD-00@starship> 
References: <E17oYth-0006wD-00@starship>  <2653.1031563253@redhat.com> 
Subject: Re: [RFC] On paging of kernel VM. 
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Date: Tue, 10 Sep 2002 07:08:27 +0100
Message-ID: <16751.1031638107@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

phillips@arcor.de said:
>  Why can't you go per-architecture and fall back to the slow way of
> doing it for architectures that don't have the new functionality yet? 

No. We can't make this kind of change to the way the vmalloc region works on
some architectures only. It has to remain uniform.

Either it's worth doing for all, or it's not. It's a fairly trivial change
in the slow path, after all. I suspect it's worth it -- I'll ask the same 
question again with a patch attached as soon as I get time, in order to 
elicit more responses.

--
dwmw2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
