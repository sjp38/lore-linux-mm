Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id A65F76B0068
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 21:29:50 -0500 (EST)
Message-ID: <1357957789.2168.11.camel@joe-AO722>
Subject: Re: mmotm 2013-01-11-15-47 uploaded (x86 asm-offsets broken)
From: Joe Perches <joe@perches.com>
Date: Fri, 11 Jan 2013 18:29:49 -0800
In-Reply-To: <20130112131713.749566c8d374cd77b1f2885e@canb.auug.org.au>
References: <20130111234813.170A620004E@hpza10.eem.corp.google.com>
	 <50F0BFAA.10902@infradead.org>
	 <20130112131713.749566c8d374cd77b1f2885e@canb.auug.org.au>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Randy Dunlap <rdunlap@infradead.org>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

On Sat, 2013-01-12 at 13:17 +1100, Stephen Rothwell wrote:
> On Fri, 11 Jan 2013 17:43:06 -0800 Randy Dunlap <rdunlap@infradead.org> wrote:
> >
> > b0rked.
> > 
> > Some (randconfig?) causes this set of errors:

I guess that's when CONFIG_HZ is not an even divisor of 1000.
I suppose this needs to be worked on a bit more.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
