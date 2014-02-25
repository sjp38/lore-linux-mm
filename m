Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 1040D6B0035
	for <linux-mm@kvack.org>; Mon, 24 Feb 2014 22:33:41 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id rr13so2956244pbb.1
        for <linux-mm@kvack.org>; Mon, 24 Feb 2014 19:33:41 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id po10si18974356pab.276.2014.02.24.19.33.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Feb 2014 19:33:40 -0800 (PST)
Message-ID: <530C0F08.1040000@oracle.com>
Date: Tue, 25 Feb 2014 11:33:28 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [LSF/MM ATTEND] slab cache extension -- slab cache in fixed size
References: <52D662A4.1080502@oracle.com> <alpine.DEB.2.10.1401310941430.6849@nuc>
In-Reply-To: <alpine.DEB.2.10.1401310941430.6849@nuc>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

Hi Christoph,

I'm so sorry for the too late response as I took a longer vacations.

On 01/31 2014 23:44 PM, Christoph Lameter wrote:
> On Wed, 15 Jan 2014, Jeff Liu wrote:
> 
>> Now I have a rough/stupid idea to add an extension to the slab caches [2], that is
>> if the slab cache size is limited which could be determined in cache_grow(), the
>> shrinker would be triggered accordingly.  I'd like to learn/know if there are any
>> suggestions and similar requirements in other subsystems.
> 
> Hmmm.... Looks like you got the right point where to insert the code to
> check for the limit. But lets leave the cache creation API the way it is.
> Add a function to set the limit?

Good idea. Yeah, changing the existing API is suboptimal than adding a new one.

In this case, another thing I'm hesitating about whether to export the cache_limit
via /proc/slabinfo by extending its tunable fields -- the per-CPU slab cache limit
and batchcount, as thus will change the user space interface and slabtop(1) need to
be modified accordingly.


Thank!

-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
