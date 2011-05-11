Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B79656B0023
	for <linux-mm@kvack.org>; Wed, 11 May 2011 16:03:24 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p4BK3NYu028731
	for <linux-mm@kvack.org>; Wed, 11 May 2011 13:03:23 -0700
Received: from pwj5 (pwj5.prod.google.com [10.241.219.69])
	by wpaz5.hot.corp.google.com with ESMTP id p4BK3HH8009240
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 11 May 2011 13:03:22 -0700
Received: by pwj5 with SMTP id 5so524821pwj.12
        for <linux-mm@kvack.org>; Wed, 11 May 2011 13:03:17 -0700 (PDT)
Date: Wed, 11 May 2011 13:03:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Slub cleanup6 1/5] slub: Use NUMA_NO_NODE in get_partial
In-Reply-To: <20110415194830.256999587@linux.com>
Message-ID: <alpine.DEB.2.00.1105111254001.9346@chino.kir.corp.google.com>
References: <20110415194811.810587216@linux.com> <20110415194830.256999587@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org

On Fri, 15 Apr 2011, Christoph Lameter wrote:

> A -1 was leftover during the conversion.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
