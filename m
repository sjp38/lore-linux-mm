Subject: Re: 2.6.0-test5-mm2
From: Luiz Capitulino <lcapitulino@prefeitura.sp.gov.br>
In-Reply-To: <20030914234843.20cea5b3.akpm@osdl.org>
References: <20030914234843.20cea5b3.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1
Message-Id: <1063636490.5588.10.camel@lorien>
Mime-Version: 1.0
Date: Mon, 15 Sep 2003 11:34:51 -0300
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rusty@rustcorp.com.au
List-ID: <linux-mm.kvack.org>

Em Seg, 2003-09-15 as 03:48, Andrew Morton escreveu:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test5/2.6.0-test5-mm2/

net/ipv4/ip_input.c: In function `ip_local_deliver_finish':
net/ipv4/ip_input.c:204: invalid suffix on integer constant
net/ipv4/ip_input.c:204: syntax error before numeric constant
make[2]: ** [net/ipv4/ip_input.o] Error 1
make[1]: ** [net/ipv4] Error 2
make: ** [net] Error 2

 this happens when CONFIG_NETFILTER_DEBUG is set. The line with
the problem are here:

#ifdef CONFIG_NETFILTER_DEBUG
        nf_debug_ip_local_deliver(skb);
        skb->nf_debug =3D 0;
#endif /*CONFIG_NETFILTER_DEBUG*/

 in the skb->nf_debug.

-- 
Luiz Fernando N. Capitulino

<lcapitulino@prefeitura.sp.gov.br>
<http://www.telecentros.sp.gov.br>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
