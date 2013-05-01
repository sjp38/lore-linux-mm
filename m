Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 77D6C6B0204
	for <linux-mm@kvack.org>; Wed,  1 May 2013 18:48:07 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id mc17so4367pbc.14
        for <linux-mm@kvack.org>; Wed, 01 May 2013 15:48:06 -0700 (PDT)
Date: Wed, 1 May 2013 15:48:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] memory_hotplug: use pgdat_resize_lock() when updating
 node_present_pages
In-Reply-To: <518199FE.7060908@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1305011547450.8804@chino.kir.corp.google.com>
References: <1367446635-12856-1-git-send-email-cody@linux.vnet.ibm.com> <1367446635-12856-5-git-send-email-cody@linux.vnet.ibm.com> <alpine.DEB.2.02.1305011530050.8804@chino.kir.corp.google.com> <518199FE.7060908@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 1 May 2013, Cody P Schafer wrote:

> Guaranteed to be stable means that if I'm a reader and pgdat_resize_lock(),
> node_present_pages had better not change at all until I pgdat_resize_unlock().
> 
> If nothing needs this guarantee, we should change the rules of
> pgdat_resize_lock(). I played it safe and went with following the existing
> rules.
> 

__offline_pages() breaks your guarantee.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
