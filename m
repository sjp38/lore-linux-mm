Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1D80C6B0253
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 20:53:38 -0400 (EDT)
Received: by pdbbh15 with SMTP id bh15so79315037pdb.1
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 17:53:37 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id h4si5057914pat.104.2015.07.28.17.53.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Jul 2015 17:53:37 -0700 (PDT)
Received: by pachj5 with SMTP id hj5so77926904pac.3
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 17:53:37 -0700 (PDT)
Date: Tue, 28 Jul 2015 17:53:32 -0700
From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: Re: hugetlb pages not accounted for in rss
Message-ID: <20150729005332.GB17938@Sligo.logfs.org>
References: <55B6BE37.3010804@oracle.com>
 <20150728183248.GB1406@Sligo.logfs.org>
 <55B7F0F8.8080909@oracle.com>
 <alpine.DEB.2.10.1507281509420.23577@chino.kir.corp.google.com>
 <20150728222654.GA28456@Sligo.logfs.org>
 <alpine.DEB.2.10.1507281622470.10368@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.10.1507281622470.10368@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, Jul 28, 2015 at 04:30:19PM -0700, David Rientjes wrote:
> 
> It's not only the oom killer, I don't believe hugeltb pages are accounted 
> to the "rss" in memcg.  They use the hugetlb_cgroup for that.  Starting to 
> account for them in existing memcg deployments would cause them to hit 
> their memory limits much earlier.  The "rss_huge" field in memcg only 
> represents transparent hugepages.
> 
> I agree with your comment that having done this when hugetlbfs was 
> introduced would have been optimal.
> 
> It's always difficult to add a new class of memory to an existing metric 
> ("new" here because it's currently unaccounted).
> 
> If we can add yet another process metric to track hugetlbfs memory mapped, 
> then the test could be converted to use that.  I'm not sure if the 
> jusitifcation would be strong enough, but you could try.

Well, we definitely need something.  Having a 100GB process show 3GB of
rss is not very useful.  How would we notice a memory leak if it only
affects hugepages, for example?

Jorn

--
The object-oriented version of 'Spaghetti code' is, of course, 'Lasagna code'.
(Too many layers).
-- Roberto Waltman.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
