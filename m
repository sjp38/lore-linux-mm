Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id C58766B0012
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 15:54:11 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id p59Js76b016318
	for <linux-mm@kvack.org>; Thu, 9 Jun 2011 12:54:09 -0700
Received: from pvh10 (pvh10.prod.google.com [10.241.210.202])
	by kpbe14.cbf.corp.google.com with ESMTP id p59Jr6M4015960
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 9 Jun 2011 12:54:06 -0700
Received: by pvh10 with SMTP id 10so962503pvh.29
        for <linux-mm@kvack.org>; Thu, 09 Jun 2011 12:54:03 -0700 (PDT)
Date: Thu, 9 Jun 2011 12:54:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: Simplify code by SECTION_ALIGN_UP() and SECTION_ALIGN_DOWN()
 macro usage
In-Reply-To: <20110609182035.GC23592@router-fw-old.local.net-space.pl>
Message-ID: <alpine.DEB.2.00.1106091251010.11607@chino.kir.corp.google.com>
References: <20110609182035.GC23592@router-fw-old.local.net-space.pl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 9 Jun 2011, Daniel Kiper wrote:

> git commit a539f3533b78e39a22723d6d3e1e11b6c14454d9 (mm: add SECTION_ALIGN_UP()
> and SECTION_ALIGN_DOWN() macro) introduced SECTION_ALIGN_UP() and SECTION_ALIGN_DOWN()
> macro. Use those macros to increase code readability.
> 
> This patch applies to Linus' git tree, v3.0-rc2 tag.
> 

 [ This patch would go through the -mm tree so it should always be based 
   on the latest git tree, no need to mention it.  Alternatively, if it 
   was based on something in -mm that isn't in the latest git yet, then
   you only need to append the "-mm" tag to the subject line:
   "[patch -mm]". ]

> Signed-off-by: Daniel Kiper <dkiper@net-space.pl>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
