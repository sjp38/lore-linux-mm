From: "George Bonser" <george@gator.com>
Subject: RE: [PATCH] 2.4.6-pre2 page_launder() improvements
Date: Sun, 10 Jun 2001 01:52:19 -0700
Message-ID: <CHEKKPICCNOGICGMDODJOEJMDEAA.george@gator.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <Pine.LNX.4.33.0106100541200.1742-100000@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>
> That sounds like the machine just gets a working set
> larger than the amount of available memory. It should
> work better with eg. 96, 128 or more MBs of memory.
>

Right, I run them with 256M ... thought I would try to squeeze it a bit to
see what broke.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
