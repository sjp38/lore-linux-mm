Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4E0B98D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 16:22:55 -0500 (EST)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p13LMaIr007081
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 13:22:36 -0800
Received: from pzk30 (pzk30.prod.google.com [10.243.19.158])
	by wpaz33.hot.corp.google.com with ESMTP id p13LMYIf001688
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 13:22:34 -0800
Received: by pzk30 with SMTP id 30so436155pzk.22
        for <linux-mm@kvack.org>; Thu, 03 Feb 2011 13:22:34 -0800 (PST)
Date: Thu, 3 Feb 2011 13:22:31 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH 4/6] pass pte size argument in to
 smaps_pte_entry()
In-Reply-To: <20110201003402.5FFC58F0@kernel>
Message-ID: <alpine.DEB.2.00.1102031318040.1307@chino.kir.corp.google.com>
References: <20110201003357.D6F0BE0D@kernel> <20110201003402.5FFC58F0@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>

On Mon, 31 Jan 2011, Dave Hansen wrote:

> 
> This patch adds an argument to the new smaps_pte_entry()
> function to let it account in things other than PAGE_SIZE
> units.  I changed all of the PAGE_SIZE sites, even though
> not all of them can be reached for transparent huge pages,
> just so this will continue to work without changes as THPs
> are improved.
> 

When signed-off:

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
