Message-ID: <3B87A3BC.EB5A9989@pp.inet.fi>
Date: Sat, 25 Aug 2001 16:10:20 +0300
From: Jari Ruusu <jari.ruusu@pp.inet.fi>
MIME-Version: 1.0
Subject: Re: VM problem with 2.4.8-ac9 (fwd)
References: <Pine.LNX.4.33L.0108241710040.31410-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Rik van Riel <riel@conectiva.com.br>, Marcelo Tosatti <marcelo@conectiva.com.br>, Hugh Dickins <hugh@veritas.com>, Jeremy Linton <jlinton@interactivesi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

VM torture results of 2.4.8-ac11, 4 hours of torture. 1 incident where a
process died with SIGSEGV.

Got these on serial console lot earlier than the SIGSEGV happened, so they
are probably unrelated to the SIGSEGV:
> Unused swap offset entry in swap_count 003cba00
> VM: Bad swap entry 003cba00

Regards,
Jari Ruusu <jari.ruusu@pp.inet.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
