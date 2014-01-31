Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 323596B0031
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 10:44:16 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id n7so7373572qcx.30
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 07:44:16 -0800 (PST)
Received: from qmta05.emeryville.ca.mail.comcast.net (qmta05.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:48])
        by mx.google.com with ESMTP id g48si7910283qge.33.2014.01.31.07.44.15
        for <linux-mm@kvack.org>;
        Fri, 31 Jan 2014 07:44:15 -0800 (PST)
Date: Fri, 31 Jan 2014 09:44:13 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [LSF/MM ATTEND] slab cache extension -- slab cache in fixed
 size
In-Reply-To: <52D662A4.1080502@oracle.com>
Message-ID: <alpine.DEB.2.10.1401310941430.6849@nuc>
References: <52D662A4.1080502@oracle.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

On Wed, 15 Jan 2014, Jeff Liu wrote:

> Now I have a rough/stupid idea to add an extension to the slab caches [2], that is
> if the slab cache size is limited which could be determined in cache_grow(), the
> shrinker would be triggered accordingly.  I'd like to learn/know if there are any
> suggestions and similar requirements in other subsystems.

Hmmm.... Looks like you got the right point where to insert the code to
check for the limit. But lets leave the cache creation API the way it is.
Add a function to set the limit?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
