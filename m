Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 80CC76B0083
	for <linux-mm@kvack.org>; Wed, 23 May 2012 20:18:36 -0400 (EDT)
Date: Thu, 24 May 2012 10:18:31 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] slab+slob: dup name string
Message-ID: <20120524001831.GQ25351@dastard>
References: <alpine.DEB.2.00.1205212018230.13522@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1205220855470.17600@router.home>
 <4FBBAE95.6080608@parallels.com>
 <alpine.DEB.2.00.1205221216050.17721@router.home>
 <alpine.DEB.2.00.1205221529340.18325@chino.kir.corp.google.com>
 <1337773595.3013.15.camel@dabdike.int.hansenpartnership.com>
 <4FBCD328.6060406@parallels.com>
 <1337775878.3013.16.camel@dabdike.int.hansenpartnership.com>
 <alpine.DEB.2.00.1205230947490.30940@router.home>
 <4FBCF951.3040105@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FBCF951.3040105@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Christoph Lameter <cl@linux.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, May 23, 2012 at 06:50:57PM +0400, Glauber Costa wrote:
> On 05/23/2012 06:48 PM, Christoph Lameter wrote:
> >On Wed, 23 May 2012, James Bottomley wrote:
> >
> >>>>So, why not simply patch slab to rely on the string lifetime being the
> >>>>cache lifetime (or beyond) and therefore not having it take a copy?
> >
> >Well thats they way it was for a long time. There must be some reason that
> >someone started to add this copying business....  Pekka?
> >
> The question is less why we added, but rather why we're keeping.
> 
> Of course reasoning about why it was added helps (so let's try to
> determine that), but so far the only reasonably strong argument in
> favor of keeping it was robustness.

I'm pretty sure it was added because there are slab names
constructed by snprintf on a stack buffer, so the name doesn't exist
beyond the slab initialisation function call...

Cheers,

Dave.

-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
