Date: Mon, 15 Sep 2003 13:59:28 -0300
From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: 2.6.0-test5-mm2
Message-ID: <20030915165928.GC1142@conectiva.com.br>
References: <20030914234843.20cea5b3.akpm@osdl.org> <1063636490.5588.10.camel@lorien>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1063636490.5588.10.camel@lorien>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Luiz Capitulino <lcapitulino@prefeitura.sp.gov.br>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rusty@rustcorp.com.au
List-ID: <linux-mm.kvack.org>

Em Mon, Sep 15, 2003 at 11:34:51AM -0300, Luiz Capitulino escreveu:
> #ifdef CONFIG_NETFILTER_DEBUG
>         nf_debug_ip_local_deliver(skb);
>         skb->nf_debug =3D 0;
                         ^^

Fixed in DaveM's tree, this kind of messages should be posted to the netfilter
and/or netdev mailing lists.

- Arnaldo
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
