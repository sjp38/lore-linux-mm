Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 174008D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 16:22:48 -0500 (EST)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p13LMiOQ003497
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 13:22:44 -0800
Received: from pvg2 (pvg2.prod.google.com [10.241.210.130])
	by hpaq1.eem.corp.google.com with ESMTP id p13LMdGh018895
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 13:22:43 -0800
Received: by pvg2 with SMTP id 2so267836pvg.16
        for <linux-mm@kvack.org>; Thu, 03 Feb 2011 13:22:43 -0800 (PST)
Date: Thu, 3 Feb 2011 13:22:41 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH 6/6] have smaps show transparent huge pages
In-Reply-To: <20110201003405.FC58B813@kernel>
Message-ID: <alpine.DEB.2.00.1102031321330.1307@chino.kir.corp.google.com>
References: <20110201003357.D6F0BE0D@kernel> <20110201003405.FC58B813@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>

On Mon, 31 Jan 2011, Dave Hansen wrote:

> 
> Now that the mere act of _looking_ at /proc/$pid/smaps will not
> destroy transparent huge pages, tell how much of the VMA is
> actually mapped with them.
> 
> This way, we can make sure that we're getting THPs where we
> expect to see them.
> 
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
