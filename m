Subject: Re: 2.6.0-test3-mm2
From: Luiz Capitulino <lcapitulino@prefeitura.sp.gov.br>
In-Reply-To: <Pine.LNX.4.44.0308131529200.1558-100000@localhost.localdomain>
References: <Pine.LNX.4.44.0308131529200.1558-100000@localhost.localdomain>
Content-Type: text/plain; charset=iso-8859-1
Message-Id: <1060791500.456.0.camel@lorien>
Mime-Version: 1.0
Date: 13 Aug 2003 13:18:20 -0300
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Con Kolivas <kernel@kolivas.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Em Qua, 2003-08-13 as 11:32, Hugh Dickins escreveu:
> On Wed, 13 Aug 2003, Con Kolivas wrote:
> > Aug 13 22:54:58 pc kernel: kernel BUG at mm/filemap.c:1930!
> 
> akpm (have you caught a moment when he's asleep?!) already posted
> the fix, saying it's a bogus BUG_ON which can be removed.

 Its working.

-- 
Luiz Fernando N. Capitulino

<lcapitulino@prefeitura.sp.gov.br>
<http://www.telecentros.sp.gov.br>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
