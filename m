Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id B9A916B0039
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 21:10:54 -0400 (EDT)
Date: Tue, 16 Jul 2013 10:10:55 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0/9] mm, hugetlb: clean-up and possible bug fix
Message-ID: <20130716011054.GC2430@lge.com>
References: <1373881967-16153-1-git-send-email-iamjoonsoo.kim@lge.com>
 <871u6zkj7b.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <871u6zkj7b.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 15, 2013 at 07:40:16PM +0530, Aneesh Kumar K.V wrote:
> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
> 
> > First 5 patches are almost trivial clean-up patches.
> >
> > The others are for fixing three bugs.
> > Perhaps, these problems are minor, because this codes are used
> > for a long time, and there is no bug reporting for these problems.
> >
> > These patches are based on v3.10.0 and
> > passed sanity check of libhugetlbfs.
> 
> does that mean you had run with libhugetlbfs test suite ?

Yes! I can't find any reggression on libhugetlbfs test suite.

>  
> -aneesh
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
