Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 309606B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 13:01:09 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id ea20so508147lab.41
        for <linux-mm@kvack.org>; Tue, 20 Aug 2013 10:01:07 -0700 (PDT)
Date: Tue, 20 Aug 2013 21:01:05 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH -mm] docs: Document soft dirty behaviour for freshly
 created memory regions
Message-ID: <20130820170105.GM18673@moon>
References: <20130820153132.GK18673@moon>
 <5213A002.7020408@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5213A002.7020408@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Pavel Emelyanov <xemul@parallels.com>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Peter Zijlstra <peterz@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On Tue, Aug 20, 2013 at 09:57:38AM -0700, Randy Dunlap wrote:
> >  
> > +  While in most cases tracking memory changes by #PF-s is more than enough
>                                                                        enough,

?

For the rest -- thanks a LOT Randy, I'll update.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
