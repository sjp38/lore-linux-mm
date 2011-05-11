Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C48ED900001
	for <linux-mm@kvack.org>; Wed, 11 May 2011 16:03:54 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id p4BK3bQW032529
	for <linux-mm@kvack.org>; Wed, 11 May 2011 13:03:37 -0700
Received: from pvc30 (pvc30.prod.google.com [10.241.209.158])
	by kpbe14.cbf.corp.google.com with ESMTP id p4BK2tJn021689
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 11 May 2011 13:03:35 -0700
Received: by pvc30 with SMTP id 30so511175pvc.34
        for <linux-mm@kvack.org>; Wed, 11 May 2011 13:03:35 -0700 (PDT)
Date: Wed, 11 May 2011 13:03:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Slub cleanup6 5/5] slub: Move debug handlign in __slab_free
In-Reply-To: <20110415194832.574871056@linux.com>
Message-ID: <alpine.DEB.2.00.1105111259270.9346@chino.kir.corp.google.com>
References: <20110415194811.810587216@linux.com> <20110415194832.574871056@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org

On Fri, 15 Apr 2011, Christoph Lameter wrote:

> Its easier to read if its with the check for debugging flags.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: David Rientjes <rientjes@google.com>

Nice reduction in an unnecessary label and goto :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
