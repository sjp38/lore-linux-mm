Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id ED1786B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 16:07:52 -0400 (EDT)
Received: by mail-qa0-f47.google.com with SMTP id o19so1274503qap.20
        for <linux-mm@kvack.org>; Wed, 14 Aug 2013 13:07:51 -0700 (PDT)
Date: Wed, 14 Aug 2013 16:07:48 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v7 2/2] mm: make lru_add_drain_all() selective
Message-ID: <20130814200748.GI28628@htj.dyndns.org>
References: <520AAF9C.1050702@tilera.com>
 <201308132307.r7DN74M5029053@farm-0021.internal.tilera.com>
 <20130813232904.GJ28996@mtj.dyndns.org>
 <520AC215.4050803@tilera.com>
 <20130813234629.4ce2ec70.akpm@linux-foundation.org>
 <520BAA5B.9070407@tilera.com>
 <20130814165723.GE28628@htj.dyndns.org>
 <520BBBE7.7020302@tilera.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <520BBBE7.7020302@tilera.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Hello, Chris.

On Wed, Aug 14, 2013 at 01:18:31PM -0400, Chris Metcalf wrote:
> On 8/14/2013 12:57 PM, Tejun Heo wrote:
> > Hello, Chris.
> >
> > On Wed, Aug 14, 2013 at 12:03:39PM -0400, Chris Metcalf wrote:
> >> Tejun, I don't know if you have a better idea for how to mark a
> >> work_struct as being "not used" so we can set and test it here.
> >> Is setting entry.next to NULL good?  Should we offer it as an API
> >> in the workqueue header?
> > Maybe simply defining a static cpumask would be cleaner?
> 
> I think you're right, actually.  Andrew, Tejun, how does this look?

Looks good to me.  Please feel free to add

 Reviewed-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
