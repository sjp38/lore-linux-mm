Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 7A3B26B005D
	for <linux-mm@kvack.org>; Wed, 30 May 2012 20:55:57 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so846182pbb.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 17:55:56 -0700 (PDT)
Date: Wed, 30 May 2012 17:55:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -V7 01/14] hugetlb: rename max_hstate to
 hugetlb_max_hstate
In-Reply-To: <1338388739-22919-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.00.1205301755420.25774@chino.kir.corp.google.com>
References: <1338388739-22919-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1338388739-22919-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>

On Wed, 30 May 2012, Aneesh Kumar K.V wrote:

> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> Rename max_hstate to hugetlb_max_hstate.  We will be using this from other
> subsystems like hugetlb controller in later patches.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Hillf Danton <dhillf@gmail.com>
> Acked-by: Michal Hocko <mhocko@suse.cz>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
