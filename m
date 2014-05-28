Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id BC54A6B0036
	for <linux-mm@kvack.org>; Tue, 27 May 2014 20:10:07 -0400 (EDT)
Received: by mail-yk0-f175.google.com with SMTP id 131so7724413ykp.20
        for <linux-mm@kvack.org>; Tue, 27 May 2014 17:10:07 -0700 (PDT)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id i41si27893802yhk.162.2014.05.27.17.10.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 27 May 2014 17:10:07 -0700 (PDT)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Tue, 27 May 2014 18:10:06 -0600
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id C37E21FF003E
	for <linux-mm@kvack.org>; Tue, 27 May 2014 18:10:02 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp08028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4S0A2oH3604892
	for <linux-mm@kvack.org>; Wed, 28 May 2014 02:10:03 +0200
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4S0A2tU020026
	for <linux-mm@kvack.org>; Tue, 27 May 2014 18:10:02 -0600
Date: Tue, 27 May 2014 17:09:58 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH v2 1/2] powerpc: numa: enable USE_PERCPU_NUMA_NODE_ID
Message-ID: <20140528000958.GF4104@linux.vnet.ibm.com>
References: <20140516233945.GI8941@linux.vnet.ibm.com>
 <20140519181423.GL8941@linux.vnet.ibm.com>
 <20140527234420.GE4104@linux.vnet.ibm.com>
 <1401234974.8262.8.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1401234974.8262.8.camel@pasglop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Anton Blanchard <anton@samba.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linuxppc-dev@lists.ozlabs.org

On 28.05.2014 [09:56:14 +1000], Benjamin Herrenschmidt wrote:
> On Tue, 2014-05-27 at 16:44 -0700, Nishanth Aravamudan wrote:
> > > Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
> > 
> > Ping on this and patch 2/2. Ben, would you be willing to pull these
> > into
> > your -next branch so they'd get some testing?
> > 
> > http://patchwork.ozlabs.org/patch/350368/
> > http://patchwork.ozlabs.org/patch/349838/
> > 
> > Without any further changes, these two help quite a bit with the slab
> > consumption on CONFIG_SLUB kernels when memoryless nodes are present.
> 
> I don't mind at all :-) I haven't really been following that story
> so I was waiting for the dust to settle and maybe acks from MM people
> but if you tell me they are good I'm prepared to trust you.

The patches themselves are pretty minimal and similar to the ia64
changes (and the affected code seems like it hasn't changed in some
time, beyond in the common code). I'd mostly like to get some
broad-range build & boot testing.

Also, is NUMA a sufficient symbol to depend, you think? I figure most of
the PPC NUMA systems are the pSeries/IBM variety, which is where I've
run into memoryless nodes in the first place.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
