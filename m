Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 3A03B6B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 17:43:23 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id n6so885414lbi.22
        for <linux-mm@kvack.org>; Tue, 20 Aug 2013 14:43:21 -0700 (PDT)
Date: Wed, 21 Aug 2013 01:43:18 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH -mm] docs: Document soft dirty behaviour for freshly
 created memory regions
Message-ID: <20130820214318.GP18673@moon>
References: <20130820153132.GK18673@moon>
 <1377033353.2737.80@driftwood>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1377033353.2737.80@driftwood>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Landley <rob@landley.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Pavel Emelyanov <xemul@parallels.com>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Peter Zijlstra <peterz@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On Tue, Aug 20, 2013 at 04:15:53PM -0500, Rob Landley wrote:
> On 08/20/2013 10:31:32 AM, Cyrill Gorcunov wrote:
> >Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> >Cc: Pavel Emelyanov <xemul@parallels.com>
> >Cc: Andy Lutomirski <luto@amacapital.net>
> >Cc: Andrew Morton <akpm@linux-foundation.org>
> >Cc: Matt Mackall <mpm@selenic.com>
> >Cc: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
> >Cc: Marcelo Tosatti <mtosatti@redhat.com>
> >Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
> >Cc: Stephen Rothwell <sfr@canb.auug.org.au>
> >Cc: Peter Zijlstra <peterz@infradead.org>
> >Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> With that cc: list, I'll assume you do _not_ want the Documentation
> maintainer paying attention to it.

Hmm, I must admit I don't know whis else list should be CC'ed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
