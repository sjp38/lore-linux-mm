Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 75E696B00C3
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 09:29:46 -0400 (EDT)
Received: by mail-ig0-f181.google.com with SMTP id h3so524484igd.14
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 06:29:46 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id g10si6824192icm.99.2014.06.13.06.29.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Jun 2014 06:29:45 -0700 (PDT)
Message-ID: <539AFCBF.1040505@oracle.com>
Date: Fri, 13 Jun 2014 09:29:35 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm/fs: gpf when shrinking slab
References: <539AF460.4000400@oracle.com> <539AF4A6.9060707@oracle.com> <20140613130026.GF18016@ZenIV.linux.org.uk>
In-Reply-To: <20140613130026.GF18016@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Christoph Lameter <cl@gentwo.org>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>

On 06/13/2014 09:00 AM, Al Viro wrote:
> On Fri, Jun 13, 2014 at 08:55:02AM -0400, Sasha Levin wrote:
>> Hand too fast on the trigger... sorry.
>>
>> It happened while fuzzing inside a KVM tools guest on the latest -next kernel. Seems
>> to be pretty difficult to reproduce.
> 
> Does that kernel contain c2338f?
> 

Nope, it didn't.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
