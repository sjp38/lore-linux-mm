Subject: Re: [PATCH] fix for VM  test9-pre7
References: <Pine.LNX.4.21.0010021411400.22539-100000@duckman.distro.conectiva>
From: Christoph Rohland <cr@sap.com>
Date: 04 Oct 2000 09:45:20 +0200
In-Reply-To: Rik van Riel's message of "Mon, 2 Oct 2000 14:17:55 -0300 (BRST)"
Message-ID: <qwwaeclxd67.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-kernel@vger.redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> On 2 Oct 2000, Christoph Rohland wrote:
> 
> > the shm swapping still kills the machine(8GB mem) the machine
> > with somthing like '__alloc_pages failed order 0'.
> > 
> > When I do the same stresstest with mmaped file in ext2 the
> > machine runs fine but the processes do not do anything and
> > vmstat/ps lock up on these processes.
> 
> This may be a highmem bounce-buffer creation deadlock. Do
> your tests work if you use only 800 MB of RAM ?
> 
> Shared memory swapping on my 64 MB test machine seems to
> work fine (albeit a bit slow).

Yupp, with mem=850M it seems to work.

Greetings
		Christoph

-- 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
