Subject: Re: the new VM
References: <Pine.LNX.4.21.0010061310290.13585-100000@duckman.distro.conectiva>
From: Christoph Rohland <cr@sap.com>
Date: 09 Oct 2000 09:37:24 +0200
In-Reply-To: Rik van Riel's message of "Fri, 6 Oct 2000 13:14:37 -0300 (BRST)"
Message-ID: <qwwk8biwjm3.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> Hmmm, could you help me with drawing up a selection algorithm
> on how to choose which SHM segment to destroy when we run OOM?
> 
> The criteria would be about the same as with normal programs:
> 
> 1) minimise the amount of work lost
> 2) try to protect 'innocent' stuff
> 3) try to kill only one thing
> 4) don't surprise the user, but chose something that
>    the user will expect to be killed/destroyed

First we only kill segments with no attachees. There are circumstances
under normal load where you have these. (SAP R/3 will do this all the
time on Linux 2.4) 

So perhaps we could signal shm that we killed a process and let it try
to find a segment where this process was the last attachee. This would
be a good candidate.

If this does not help either we could do two different things:
1) kill the biggest nonattached segment
2) kill the segment which was longest detached

Greetings
		Christoph

-- 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
