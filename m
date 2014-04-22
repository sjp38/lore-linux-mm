Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3894F6B0070
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 19:19:56 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id bj1so124922pad.3
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 16:19:55 -0700 (PDT)
Received: from mail-pb0-x22c.google.com (mail-pb0-x22c.google.com [2607:f8b0:400e:c01::22c])
        by mx.google.com with ESMTPS id ps1si2614775pbc.336.2014.04.22.16.19.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 16:19:54 -0700 (PDT)
Received: by mail-pb0-f44.google.com with SMTP id rp16so121817pbb.31
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 16:19:54 -0700 (PDT)
Date: Tue, 22 Apr 2014 16:19:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: debug: make bad_range() output more usable and
 readable
In-Reply-To: <20140421180733.30BD5EFE@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.02.1404221619150.16896@chino.kir.corp.google.com>
References: <20140421180733.30BD5EFE@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, dave.hansen@linux.intel.com

On Mon, 21 Apr 2014, Dave Hansen wrote:

> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> Nobody outputs memory addresses in decimal.  PFNs are essentially
> addresses, and they're gibberish in decimal.  Output them in hex.
> 
> Also, add the nid and zone name to give a little more context to
> the message.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
