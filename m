Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5BE516B02A4
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 13:54:33 -0400 (EDT)
From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [patch 2/6] infiniband: remove dependency on __GFP_NOFAIL
References: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1007201938570.8728@chino.kir.corp.google.com>
	<4C466730.1070809@opengridcomputing.com>
Date: Wed, 21 Jul 2010 10:55:36 -0700
In-Reply-To: <4C466730.1070809@opengridcomputing.com> (Steve Wise's message of
	"Tue, 20 Jul 2010 22:19:12 -0500")
Message-ID: <adaaapkpvmv.fsf@roland-alpha.cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Steve Wise <swise@opengridcomputing.com>
Cc: David Rientjes <rientjes@google.com>, Steve Wise <swise@chelsio.com>, Andrew Morton <akpm@linux-foundation.org>, Roland Dreier <rolandd@cisco.com>, linux-rdma@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

thanks guys, applied
-- 
Roland Dreier <rolandd@cisco.com> || For corporate legal information go to:
http://www.cisco.com/web/about/doing_business/legal/cri/index.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
