Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 7519B6B002C
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 18:53:26 -0500 (EST)
Received: by obbta14 with SMTP id ta14so9935010obb.14
        for <linux-mm@kvack.org>; Wed, 07 Mar 2012 15:53:25 -0800 (PST)
Date: Wed, 7 Mar 2012 15:53:23 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: decode GFP flags in oom killer output.
In-Reply-To: <20120307233939.GB5574@redhat.com>
Message-ID: <alpine.DEB.2.00.1203071548200.29642@chino.kir.corp.google.com>
References: <20120307233939.GB5574@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed, 7 Mar 2012, Dave Jones wrote:

> Decoding these flags by hand in oom reports is tedious,
> and error-prone.
> 

Something like this is already done in include/trace/events/gfpflags.h so 
there should be a generic version of this or something you can already 
use.

The problem here is that you have to allocate an additional 80-bytes for 
the string and the oom killer is notorious for being called deep in the 
stack and you can't statically allocate a string buffer without adding 
additional syncronization.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
