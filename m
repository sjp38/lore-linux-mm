Subject: Re: [PATCH] VM kswapd autotuning vs. -ac7
References: <Pine.LNX.4.21.0006031746410.5754-100000@duckman.distro.conectiva>
From: Christoph Rohland <cr@sap.com>
Date: 04 Jun 2000 13:12:10 +0200
In-Reply-To: Rik van Riel's message of "Sat, 3 Jun 2000 17:47:37 -0300 (BRST)"
Message-ID: <qww7lc5wvhx.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Christoph Rohland <cr@sap.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> Patch #2 indeed had a big bug that made all systems crash instead
> of use swap (missing braces next to a goto), does patch #3 give you
> the same behaviour?

>From a short view #3 looks much better, but one thing is disturbing me:

12  0  0      0 492440   1604  10200   0   0     0     0  104 72356   5  94   1
shmget: Cannot allocate memory
 9  2  1   8992 610136    148  13840   0 1798     3   452 1581 83181   0  90   9

it begins swapping with 490MB free and fails to allocate a shm segment?

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
