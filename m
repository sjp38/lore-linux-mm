Message-ID: <39DA787E.B31422B4@sgi.com>
Date: Tue, 03 Oct 2000 17:23:26 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Odd swap behavior
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com.br
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


I'm running fairly stressful tests like
dbench with lots of clients. Since the new
VM changes (now in test9), I haven't noticed _any_ swap activity,
in spite of the enormous memory pressures. I have lots
of processes in the system, like 8 httpd's, 4 getty's, etc.
most of which should be "idle" ... Why aren't the
pages (eg. mapped stacks) from these processes being swapped out?


--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
