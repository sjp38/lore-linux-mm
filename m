Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id C1F696B009B
	for <linux-mm@kvack.org>; Fri, 13 Feb 2015 18:52:47 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id l2so19596735wgh.9
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 15:52:47 -0800 (PST)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id eh10si6803882wib.98.2015.02.13.15.52.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Feb 2015 15:52:46 -0800 (PST)
Message-ID: <54DE8E47.5040800@canonical.com>
Date: Fri, 13 Feb 2015 17:52:39 -0600
From: Chris J Arges <chris.j.arges@canonical.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: slub: Add SLAB_DEBUG_CRASH option
References: <1423865980-10417-1-git-send-email-chris.j.arges@canonical.com> <1423865980-10417-3-git-send-email-chris.j.arges@canonical.com> <alpine.DEB.2.10.1502131537430.25326@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1502131537430.25326@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org



On 02/13/2015 05:38 PM, David Rientjes wrote:
> On Fri, 13 Feb 2015, Chris J Arges wrote:
> 
>> This option crashes the kernel whenever corruption is initially detected. This
>> is useful when trying to use crash dump analysis to determine where memory was
>> corrupted.
>>
>> To enable this option use slub_debug=C.
>>
> 
> Why isn't this done in other debugging functions such as 
> free_debug_processing()?
> 

The diff doesn't show this clearly, but the BUG_ON was added to both
free_debug_processing and alloc_debug_processing.

--chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
