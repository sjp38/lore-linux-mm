Date: Wed, 15 Aug 2001 07:32:39 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] 2.4.8-ac5 VM changes
Message-ID: <Pine.LNX.4.33L.0108150728090.5646-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: Alan Cox <alan@lxorguk.ukuu.org.uk>, <linux-mm@kvack.org>
ReSent-Message-ID: <Pine.LNX.4.33L.0108151411570.5646@imladris.rielhome.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Alan,

the following patch implements these (trivial) things,
which clean up the code slightly and will give us the
opportunity to experiment with the VM by tuning some
parameters at run-time:

1) merge the page_age*() cleanups from -linus

2) make /proc/sys/vm/freepages writeable again

3) switch the page aging tactic in /proc/sys/vm:
     0)  no page aging
     1)  exponential decline   * current, default
     2)  linear decline        * Linux 2.0, FreeBSD

4) specify a static inactive_target in /proc/sys/vm,
   this can be good for some specific workloads, but
   seems mostly useful for VM experimenting and tuning

Note that this patch does not modify the default behaviour
of the kernel.

Please apply for the next -ac.

thanks,

Rik
--
IA64: a worthy successor to i860.

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
