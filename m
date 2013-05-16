Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 7DF796B0033
	for <linux-mm@kvack.org>; Thu, 16 May 2013 17:05:08 -0400 (EDT)
Received: by mail-da0-f51.google.com with SMTP id h15so1901095dan.10
        for <linux-mm@kvack.org>; Thu, 16 May 2013 14:05:07 -0700 (PDT)
Date: Thu, 16 May 2013 14:05:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3 3/4] memory_hotplug: use pgdat_resize_lock() in
 online_pages()
In-Reply-To: <20130515162054.1c76200ee9514ca8a2054628@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1305161404470.1348@chino.kir.corp.google.com>
References: <1368486787-9511-1-git-send-email-cody@linux.vnet.ibm.com> <1368486787-9511-4-git-send-email-cody@linux.vnet.ibm.com> <20130515162054.1c76200ee9514ca8a2054628@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Cody P Schafer <cody@linux.vnet.ibm.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 15 May 2013, Andrew Morton wrote:

> On Mon, 13 May 2013 16:13:06 -0700 Cody P Schafer <cody@linux.vnet.ibm.com> wrote:
> 
> > mmzone.h documents node_size_lock (which pgdat_resize_lock() locks) as
> > follows:
> > 
> >         * Must be held any time you expect node_start_pfn, node_present_pages
> >         * or node_spanned_pages stay constant.  [...]
> 
> Yeah, I suppose so.  Although no present code sites actually do that.
> 

Agreed, I see no purpose in patches 2-4 in this series as mentioned in v2.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
