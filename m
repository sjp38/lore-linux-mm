Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5FF346B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 18:41:10 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id vb8so8621002obc.4
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 15:41:10 -0800 (PST)
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com. [32.97.110.153])
        by mx.google.com with ESMTPS id ns8si10630540obc.87.2014.02.03.15.41.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 15:41:09 -0800 (PST)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 3 Feb 2014 16:41:09 -0700
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 5A7783E4003F
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 16:41:07 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08025.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s13Nf79q62718034
	for <linux-mm@kvack.org>; Tue, 4 Feb 2014 00:41:07 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s13NiPaN013113
	for <linux-mm@kvack.org>; Mon, 3 Feb 2014 16:44:26 -0700
Date: Mon, 3 Feb 2014 15:41:05 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Kernel WARNING splat in 3.14-rc1
Message-ID: <20140203234105.GA10614@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <52EFF658.2080001@lwfinger.net>
 <alpine.DEB.2.02.1402031236250.7898@chino.kir.corp.google.com>
 <52F0215B.5040209@lwfinger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52F0215B.5040209@lwfinger.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Feb 03, 2014 at 05:08:11PM -0600, Larry Finger wrote:
> On 02/03/2014 02:39 PM, David Rientjes wrote:
> >Commit c65c1877bd68 ("slub: use lockdep_assert_held") incorrectly required
> >that add_full() and remove_full() hold n->list_lock.  The lock is only
> >taken when kmem_cache_debug(s), since that's the only time it actually
> >does anything.
> >
> >Require that the lock only be taken under such a condition.
> >
> >Reported-by: Larry Finger <Larry.Finger@lwfinger.net>
> >Signed-off-by: David Rientjes <rientjes@google.com>
> 
> You may add a "Tested-by: Larry Finger <Larry.Finger@lwfinger.net>".
> The patch cleans up the splat on my system. Thanks for the quick
> response.

Please feel free to add mine as well:

Tested-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

And also feel free to ignore my patch as well.  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
