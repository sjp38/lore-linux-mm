From: Christoph Rohland <cr@sap.com>
Subject: Re: Looking for better VM
References: <Pine.LNX.3.96.1001108172338.7153A-100000@artax.karlin.mff.cuni.cz>
Date: 08 Nov 2000 18:03:09 +0100
In-Reply-To: Mikulas Patocka's message of "Wed, 8 Nov 2000 17:36:40 +0100 (CET)"
Message-ID: <qwwr94ml7le.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
Cc: Rik van Riel <riel@conectiva.com.br>, Szabolcs Szakacsits <szaka@f-secure.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Hi Mikulas,

On Wed, 8 Nov 2000, Mikulas Patocka wrote:
> BTW. Why does your OOM killer in 2.4 try to kill process that mmaped
> most memory? mmap is hamrless. mmap on files can't eat memory and
> swap.

Be careful: They may have shm segments mmaped!

Greetings
		Christoph

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
