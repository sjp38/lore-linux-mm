Subject: Re: [PATCH] VM kswapd autotuning vs. -ac7
References: <Pine.LNX.4.21.0006011910340.1172-100000@duckman.distro.conectiva>
From: Christoph Rohland <cr@sap.com>
Date: 02 Jun 2000 17:54:04 +0200
In-Reply-To: Rik van Riel's message of "Thu, 1 Jun 2000 19:31:24 -0300 (BRST)"
Message-ID: <qwwln0ow02r.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Rik,

This patch still does not allow swapping with shm. Instead it kills
all runnable processes without message.

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
