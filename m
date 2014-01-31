Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7E51D6B0035
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 19:49:42 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id un15so3834482pbc.10
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 16:49:42 -0800 (PST)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id ek3si8381672pbd.235.2014.01.30.16.49.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 16:49:41 -0800 (PST)
Received: by mail-pa0-f50.google.com with SMTP id kp14so3822516pab.37
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 16:49:41 -0800 (PST)
Date: Thu, 30 Jan 2014 16:49:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Documentation: fix memmap= language in
 kernel-parameters.txt
In-Reply-To: <52EAEFD8.6030003@infradead.org>
Message-ID: <alpine.DEB.2.02.1401301649280.32652@chino.kir.corp.google.com>
References: <52EAEFD8.6030003@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andiry Xu <andiry.xu@gmail.com>, Rob Landley <rob@landley.net>

On Thu, 30 Jan 2014, Randy Dunlap wrote:

> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Clean up descriptions of memmap= boot options.
> 
> Add periods (full stops), drop commas, change "used" to
> "reserved" or "marked".
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
> Cc: Andiry Xu <andiry.xu@gmail.com>
> Cc: David Rientjes <rientjes@google.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
