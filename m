Message-ID: <3B8BBD94.B57510A2@pp.inet.fi>
Date: Tue, 28 Aug 2001 18:49:40 +0300
From: Jari Ruusu <jari.ruusu@pp.inet.fi>
MIME-Version: 1.0
Subject: Re: VM problem with 2.4.8-ac9 (fwd)
References: <Pine.LNX.4.33L.0108241710040.31410-100000@duckman.distro.conectiva> <3B87A3BC.EB5A9989@pp.inet.fi>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Rik van Riel <riel@conectiva.com.br>, Marcelo Tosatti <marcelo@conectiva.com.br>, Hugh Dickins <hugh@veritas.com>, Jeremy Linton <jlinton@interactivesi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2.4.8-ac12
~~~~~~~~~~
5 hours of VM torture. 1 incident where a process died with SIGSEGV.

Got these on serial console:
> Unused swap offset entry in swap_dup 0007e400
> VM: Bad swap entry 0007e400
> Unused swap offset entry in swap_count 0007e400
> Unused swap offset entry in swap_count 0007e400
> Unused swap offset entry in swap_count 0007e400
> VM: Bad swap entry 0007e400

2.4.9-ac1
~~~~~~~~~
13 hours of VM torture. 2 incidents where a process died with SIGSEGV. No
"swap offset" messages. Both SIGSEGV incidents appeared to happen
simultaneously, suggesting that one erratic behavior caused both.

2.4.9-ac3
~~~~~~~~~
Kernel compiled with -fno-strength-reduce. 3 hours of VM torture. 2
incidents where a process died with SIGSEGV. No "swap offset" messages. Both
SIGSEGV incidents appeared to happen simultaneously, suggesting that one
erratic behavior caused both.

2.4.10-pre1
~~~~~~~~~~~
2 hours of VM torture. 1 incident where a process died with SIGSEGV. No
"swap offset" messages.

Regards,
Jari Ruusu <jari.ruusu@pp.inet.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
