Subject: Re: 2.6.0-test7-mm1
From: Luiz Capitulino <lcapitulino@prefeitura.sp.gov.br>
In-Reply-To: <20031015214004.GC723@holomorphy.com>
References: <20031015013649.4aebc910.akpm@osdl.org>
	 <1066232576.25102.1.camel@telecentrolivre>
	 <20031015165508.GA723@holomorphy.com> <20031015214004.GC723@holomorphy.com>
Content-Type: text/plain; charset=iso-8859-1
Message-Id: <1066317063.2601.3.camel@telecentrolivre>
Mime-Version: 1.0
Date: Thu, 16 Oct 2003 13:11:03 -0200
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi William,

Em Qua, 2003-10-15 as 19:40, William Lee Irwin III escreveu:
> On Wed, Oct 15, 2003 at 09:55:08AM -0700, William Lee Irwin III wrote:
> > Okay, this one's me. I should have tried DEBUG_PAGEALLOC when testing.
> 
> I can't reproduce it here, can you retry with the invalidate_inodes-speedup
> patch backed out?

yes, it works without invalidate_inodes-speedup.

(sorry for the delay).

-- 
Luiz Fernando N. Capitulino
<lcapitulino@prefeitura.sp.gov.br>
<http://www.telecentros.sp.gov.br>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
