Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 713046B0002
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 06:24:45 -0400 (EDT)
Date: Thu, 18 Apr 2013 12:24:38 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH] slab: Remove unnecessary __builtin_constant_p()
Message-ID: <20130418102438.GA21722@pd.tnic>
References: <1366225776.8817.28.camel@pippen.local.home>
 <516F3B30.30307@gmail.com>
 <alpine.DEB.2.02.1304171731410.26200@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1304171731410.26200@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Will Huck <will.huckk@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Behan Webster <behanw@converseincode.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Apr 17, 2013 at 05:32:03PM -0700, David Rientjes wrote:
> On Thu, 18 Apr 2013, Will Huck wrote:
> 
> > In normal case, builtin_constant_p() is used for what?
> > 
> http://gcc.gnu.org/onlinedocs/

Yeah, there's also this very educating site for situations like this
one:

http://lmgtfy.com

:-)

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
