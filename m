Subject: Re: [PATCH] fix for VM  test9-pre7
References: <Pine.LNX.4.21.0010020038090.30717-100000@duckman.distro.conectiva>
From: Christoph Rohland <cr@sap.com>
Date: 02 Oct 2000 18:46:10 +0200
In-Reply-To: Rik van Riel's message of "Mon, 2 Oct 2000 00:42:47 -0300 (BRST)"
Message-ID: <qwwu2avxkbx.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-kernel@vger.redhat.com, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi Rik,

the shm swapping still kills the machine(8GB mem) the machine with
somthing like '__alloc_pages failed order 0'. 

When I do the same stresstest with mmaped file in ext2 the machine
runs fine but the processes do not do anything and vmstat/ps lock up
on these processes.

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
