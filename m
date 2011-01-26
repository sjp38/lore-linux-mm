Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EEE316B0092
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 05:45:47 -0500 (EST)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id p0QAjgTL016104
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 02:45:42 -0800
Received: from iyj17 (iyj17.prod.google.com [10.241.51.81])
	by kpbe20.cbf.corp.google.com with ESMTP id p0QAjc7c009519
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 02:45:40 -0800
Received: by iyj17 with SMTP id 17so291221iyj.0
        for <linux-mm@kvack.org>; Wed, 26 Jan 2011 02:45:38 -0800 (PST)
Date: Wed, 26 Jan 2011 02:45:34 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: known oom issues on numa in -mm tree?
In-Reply-To: <976317569.44499.1294739187129.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Message-ID: <alpine.DEB.2.00.1101260244310.27469@chino.kir.corp.google.com>
References: <976317569.44499.1294739187129.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: CAI Qian <caiqian@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 11 Jan 2011, CAI Qian wrote:

> BTW, the latest linux-next also had the similar issue.
> 
> - kswapd was running for a long time.
> 

I'd be interested to see if this is fixed now that 2ff754fa8f41 (mm: clear 
pages_scanned only if draining a pcp adds pages to the buddy allocator) 
has been merged in Linus' tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
