Message-ID: <XFMail.20000128103339.gale@syntax.dera.gov.uk>
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.10.10001280155560.25452-100000@mirkwood.dummy.home>
Date: Fri, 28 Jan 2000 10:33:39 -0000 (GMT)
From: Tony Gale <gale@syntax.dera.gov.uk>
Subject: RE: [PATCH] boobytrap for 2.2.15pre5
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Linux MM <linux-mm@kvack.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

Here's my list:

kmem_cache_alloc called by non-running (1) task from c011df72!
kmem_cache_alloc called by non-running (1) task from c011dfdd!

c011dcf0 T kmem_cache_shrink
c011dde4 t kmem_cache_grow
c011e158 t kmem_report_alloc_err
c011e184 t kmem_report_free_err


kmem_cache_alloc called by non-running (1) task from c014d31e!
kmem_cache_alloc called by non-running (2) task from c014d31e!
kmem_cache_alloc called by non-running (4) task from c014d31e!

c014d15c T sock_getsockopt
c014d30c T sk_alloc
c014d348 T sk_free
c014d384 T sock_wfree


kmem_cache_alloc called by non-running (1) task from c014db98!
kmem_cache_alloc called by non-running (2) task from c014db98!
kmem_cache_alloc called by non-running (4) task from c014db98!

c014dafc T show_net_buffers
c014db40 T alloc_skb
c014dc1c T kfree_skbmem
c014dc5c T __kfree_skb


kmem_cache_alloc called by non-running (1) task from c014dd1c!
kmem_cache_alloc called by non-running (2) task from c014dd1c!
kmem_cache_alloc called by non-running (4) task from c014dd1c!

c014dd04 T skb_clone
c014dd98 T skb_copy
c014dee4 T skb_realloc_headroom


kmem_cache_alloc called by non-running (1) task from c015c53d!
kmem_cache_alloc called by non-running (2) task from c015c53d!
kmem_cache_alloc called by non-running (4) task from c015c53d!

c015c438 T tcp_timewait_state_process
c015c528 T tcp_time_wait
c015c74c t tcp_fin
c015c800 t tcp_sack_maybe_coalesce


kmem_cache_alloc called by non-running (1) task from c01618eb!
kmem_cache_alloc called by non-running (2) task from c01618eb!
kmem_cache_alloc called by non-running (4) task from c01618eb!

c01617d0 t tcp_v4_or_free
c01617f4 T tcp_v4_conn_request
c0161b48 T tcp_create_openreq_child
c0161f30 T tcp_v4_syn_recv_sock


---
E-Mail: Tony Gale <gale@syntax.dera.gov.uk>
We just joined the civil hair patrol!

The views expressed above are entirely those of the writer
and do not represent the views, policy or understanding of
any other person or official body.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
