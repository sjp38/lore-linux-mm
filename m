Date: Fri, 5 Jan 2001 14:56:40 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: MM/VM todo list
In-Reply-To: <Pine.LNX.4.21.0101051505430.1295-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0101051454230.2859-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 5 Jan 2001, Rik van Riel wrote:

> Probably 2.5 era:
> * VM: physical->virtual reverse mapping, so we can do much
>   better page aging with less CPU usage spikes 
> * VM: move all the global VM variables, lists, etc. into the
>   pgdat struct for better NUMA scalability
> * VM: per-node kswapd for NUMA
> * VM: thrashing control, maybe process suspension with some
>   forced swapping ?             (trivial only in theory)
> * VM: experiment with different active lists / aging pages
>   of different ages at different rates + other page replacement
>   improvements
> * VM: Quality of Service / fairness / ... improvements
  * VM: Use kiobuf IO in VM instead buffer_head IO. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
