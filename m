Subject: Re: 2.6.0-test6-mm2
From: Luiz Capitulino <lcapitulino@prefeitura.sp.gov.br>
In-Reply-To: <20031002080335.0f75fade.akpm@osdl.org>
References: <20031002022341.797361bc.akpm@osdl.org>
	 <1065102346.14567.12.camel@telecentrolivre>
	 <20031002080335.0f75fade.akpm@osdl.org>
Content-Type: text/plain; charset=iso-8859-1
Message-Id: <1065119384.20375.1.camel@telecentrolivre>
Mime-Version: 1.0
Date: Thu, 02 Oct 2003 15:29:44 -0300
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Em Qui, 2003-10-02 as 12:03, Andrew Morton escreveu:
> Luiz Capitulino <lcapitulino@prefeitura.sp.gov.br> wrote:
> >
> > Em Qui, 2003-10-02 as 06:23, Andrew Morton escreveu:
> >  > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test6/2.6.0-test6-mm2/
> > 
> >  getting this with gcc-3.2:
> > 
> >  net/core/flow.c:406: warning: type defaults to `int' in declaration of `EXPORT_SYMBOL'
> >  net/core/flow.c:406: warning: parameter names (without types) in function declaration
> >  net/core/flow.c:406: warning: data definition has no type or storage class
> >  net/core/flow.c:407: warning: type defaults to `int' in declaration of `EXPORT_SYMBOL'
> >  net/core/flow.c:407: warning: parameter names (without types) in function declaration
> >  net/core/flow.c:407: warning: data definition has no type or storage class
> 
> It works OK for me, and flow.c correctly includes module.h.  Could you
> double-check that your tree is not damaged in some manner?

 yes, you right.

 sorry for the bad report.

-- 
Luiz Fernando N. Capitulino
<lcapitulino@prefeitura.sp.gov.br>
<http://www.telecentros.sp.gov.br>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
