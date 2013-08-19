Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 4887C6B0032
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 17:10:15 -0400 (EDT)
Received: by mail-lb0-f178.google.com with SMTP id z5so3501521lbh.9
        for <linux-mm@kvack.org>; Mon, 19 Aug 2013 14:10:13 -0700 (PDT)
Date: Tue, 20 Aug 2013 01:10:06 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: Track vma changes with VM_SOFTDIRTY bit
Message-ID: <20130819211006.GA18673@moon>
References: <20130819195836.GO23919@moon>
 <20130819140816.6c35952c0bc19c480a9664d6@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130819140816.6c35952c0bc19c480a9664d6@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Pavel Emelyanov <xemul@parallels.com>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Peter Zijlstra <peterz@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On Mon, Aug 19, 2013 at 02:08:16PM -0700, Andrew Morton wrote:
> > 
> > Thus when user space application track memory changes
> > now it can detect if vma area is renewed.
> 
> Can we please update Documentation/vm/soft-dirty.txt for this?

Oops. Sorry, forgot about soft-dirty.txt. Sure I'll update it
later tonight or tomorrow, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
