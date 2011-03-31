Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 80BED8D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 20:58:11 -0400 (EDT)
Date: Wed, 30 Mar 2011 17:56:27 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 8/8] Add VM counters for transparent hugepages
Message-ID: <20110331005627.GD10173@tassilo.jf.intel.com>
References: <20110330144507.2c0ecf73.akpm@linux-foundation.org>
 <20110330233050.GG21838@one.firstfloor.org>
 <20110331095251.0EC3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110331095251.0EC3.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 31, 2011 at 09:52:24AM +0900, KOSAKI Motohiro wrote:
> > > Do we still want it?  Are we sure we don't want the per-zone numbers?
> > 
> > At least I still want it and Dave Hansen did too.
> > 
> > I don't need per zone personally and I remember a strong request from 
> > anyone.  Or was there one?
> 
> If my remember is correct, Only /me puted weak request of per-zone number.
> To be honest, myself never use this counter, my question was just curious.
> Then, I'm ok if Andi didn't hit any issue.

Thanks

> Andi, But, if anyone will put numa request or numa related bug report 
> in future, Perhaps I might convert it per-zone one. Is this ok?

Sure. We can always change it later.

Andrew, this means you can merge it now I think.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
