Received: from slayers.conectiva (slayers.conectiva [10.0.2.43])
	by perninha.conectiva.com.br (Postfix) with ESMTP id 00D6D38C1C
	for <linux-mm@kvack.org>; Tue, 26 Jun 2001 05:19:32 -0300 (EST)
Date: Tue, 26 Jun 2001 03:46:17 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: [PATCH] Get information about allocated and used swap space 
Message-ID: <Pine.LNX.4.21.0106260342060.1822-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, 

This patch creates a new "Allocated" field in /proc/swaps which shows what
the "Used" field used to show.

Now the "Used" field reports how much data is on swap but not in
memory. (actually used swap space)

http://bazar.conectiva.com.br/~marcelo/patches/v2.4/2.4.5ac16/show_swap_allocated.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
