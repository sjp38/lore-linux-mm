Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 457836B02F3
	for <linux-mm@kvack.org>; Fri,  3 May 2013 14:58:58 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id ro12so1051470pbb.4
        for <linux-mm@kvack.org>; Fri, 03 May 2013 11:58:57 -0700 (PDT)
Date: Fri, 3 May 2013 11:58:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 1/4] mm: fix comment referring to non-existent
 size_seqlock, change to span_seqlock
In-Reply-To: <1367451121-22725-2-git-send-email-cody@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1305031157280.7526@chino.kir.corp.google.com>
References: <1367451121-22725-1-git-send-email-cody@linux.vnet.ibm.com> <1367451121-22725-2-git-send-email-cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 1 May 2013, Cody P Schafer wrote:

> Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>

Others in this series aren't needed, in my opinion, but everybody has 
their own tastes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
