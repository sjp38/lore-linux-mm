Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6D5DF6B0038
	for <linux-mm@kvack.org>; Fri,  6 Mar 2015 16:14:45 -0500 (EST)
Received: by igbhl2 with SMTP id hl2so7241549igb.5
        for <linux-mm@kvack.org>; Fri, 06 Mar 2015 13:14:45 -0800 (PST)
Received: from mail-ie0-x22e.google.com (mail-ie0-x22e.google.com. [2607:f8b0:4001:c03::22e])
        by mx.google.com with ESMTPS id b19si12909384ioe.59.2015.03.06.13.14.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Mar 2015 13:14:45 -0800 (PST)
Received: by iebtr6 with SMTP id tr6so15735180ieb.4
        for <linux-mm@kvack.org>; Fri, 06 Mar 2015 13:14:44 -0800 (PST)
Date: Fri, 6 Mar 2015 13:14:43 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 0/3] hugetlbfs: optionally reserve all fs pages at mount
 time
In-Reply-To: <54F9F8F1.4020203@oracle.com>
Message-ID: <alpine.DEB.2.10.1503061312170.10330@chino.kir.corp.google.com>
References: <1425077893-18366-1-git-send-email-mike.kravetz@oracle.com> <20150302151009.2ae58f4430f9f34b81533821@linux-foundation.org> <54F50BD6.1030706@oracle.com> <20150306151045.GA23443@dhcp22.suse.cz> <54F9F8F1.4020203@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, 6 Mar 2015, Mike Kravetz wrote:

> Thanks for the CONFIG_CGROUP_HUGETLB suggestion, however I do not
> believe this will be a satisfactory solution for my usecase.  As you
> point out, cgroups could be set up (by a sysadmin) for every hugetlb
> user/application.  In this case, the sysadmin needs to have knowledge
> of every huge page user/application and configure appropriately.
> 
> I was approaching this from the point of view of the application.  The
> application wants the guarantee of a minimum number of huge pages,
> independent of other users/applications.  The "reserve" approach allows
> the application to set aside those pages at initialization time.  If it
> can not get the pages it needs, it can refuse to start, or configure
> itself to use less, or take other action.
> 

Would it be too difficult to modify the application to mmap() the 
hugepages at startup so they are no longer free in the global pool but 
rather get marked as reserved so other applications cannot map them?  That 
should return MAP_FAILED if there is an insufficient number of hugepages 
available to be reserved (HugePages_Rsvd in /proc/meminfo).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
