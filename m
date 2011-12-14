Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 805E16B02AE
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 21:38:45 -0500 (EST)
Received: by yhoo21 with SMTP id o21so1146377yho.14
        for <linux-mm@kvack.org>; Tue, 13 Dec 2011 18:38:44 -0800 (PST)
Date: Tue, 13 Dec 2011 18:38:41 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] slub: set a criteria for slub node partial adding
In-Reply-To: <1323830622.22361.407.camel@sli10-conroe>
Message-ID: <alpine.DEB.2.00.1112131837160.31514@chino.kir.corp.google.com>
References: <1322814189-17318-1-git-send-email-alex.shi@intel.com> <alpine.DEB.2.00.1112020842280.10975@router.home> <1323076965.16790.670.camel@debian> <alpine.DEB.2.00.1112061259210.28251@chino.kir.corp.google.com> <1323234673.22361.372.camel@sli10-conroe>
 <alpine.DEB.2.00.1112062319010.21785@chino.kir.corp.google.com> <1323657793.22361.383.camel@sli10-conroe> <alpine.DEB.2.00.1112131726140.8593@chino.kir.corp.google.com> <1323830622.22361.407.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: "Shi, Alex" <alex.shi@intel.com>, Christoph Lameter <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <ak@linux.intel.com>

On Wed, 14 Dec 2011, Shaohua Li wrote:

> if vast majority of allocation needs picking from partial list of node,
> the list_lock will have contention too. But I'd say avoiding the slab
> thrashing does increase fastpath.

Right, that's why my 2009 patchset would attempt to grab the partial slab 
with the highest number of free objects to a certain threshold before 
falling back to others and it improved performance somewhat.  This was 
with the per-node partial lists, however, and the slowpath has been 
significantly rewritten since then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
