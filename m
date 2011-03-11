Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 55C108D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 18:08:45 -0500 (EST)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p2BN8ggf013977
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 15:08:42 -0800
Received: from pxi7 (pxi7.prod.google.com [10.243.27.7])
	by hpaq14.eem.corp.google.com with ESMTP id p2BN84Rx020546
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 15:08:40 -0800
Received: by pxi7 with SMTP id 7so805604pxi.16
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 15:08:38 -0800 (PST)
Date: Fri, 11 Mar 2011 15:08:32 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH 00/25]: Propagating GFP_NOFS inside __vmalloc()
In-Reply-To: <AANLkTimu-42CC3pv57njj6-UqwDO3iNLtiem9=y9ggng@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1103111505450.4900@chino.kir.corp.google.com>
References: <AANLkTimU2QGc_BVxSWCN8GEhr8hCOi1Zp+eaA20_pE-w@mail.gmail.com> <alpine.DEB.2.00.1103111258340.31216@chino.kir.corp.google.com> <AANLkTimu-42CC3pv57njj6-UqwDO3iNLtiem9=y9ggng@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prasad Joshi <prasadjoshi124@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Anand Mitra <mitra@kqinfotech.com>

On Fri, 11 Mar 2011, Prasad Joshi wrote:

> Thanks a lot for your reply. I should have seen your mail before
> sending 23 mails :(
> I will make the changes suggested by you and will resend all of the
> patches again.
> 

Thanks for taking this effort on.  A couple other points:

 - each patch should have a different subject prefixed with the subsystem 
   that it touches (for example: "x86: add gfp flags variant of 
   pte_alloc_one") and the maintainers should be cc'd.  Check 
   scripts/get_maintainer.pl or the MAINTAINERS file.  Also, for changes 
   that touch all arch code you'll want to cc linux-arch@vger.kernel.org 
   as well.

 - each change needs to have a proper changelog prior to your
   signed-off-by line to explain why the change is being done and in 
   preparation for supporting non-GFP_KERNEL allocations from __vmalloc().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
