Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 8300A6B00D3
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 20:32:06 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id bh4so1172402pad.40
        for <linux-mm@kvack.org>; Wed, 17 Apr 2013 17:32:05 -0700 (PDT)
Date: Wed, 17 Apr 2013 17:32:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slab: Remove unnecessary __builtin_constant_p()
In-Reply-To: <516F3B30.30307@gmail.com>
Message-ID: <alpine.DEB.2.02.1304171731410.26200@chino.kir.corp.google.com>
References: <1366225776.8817.28.camel@pippen.local.home> <516F3B30.30307@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Huck <will.huckk@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Behan Webster <behanw@converseincode.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 18 Apr 2013, Will Huck wrote:

> In normal case, builtin_constant_p() is used for what?
> 

http://gcc.gnu.org/onlinedocs/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
