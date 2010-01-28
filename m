Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8AF916B007E
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 03:32:35 -0500 (EST)
Date: Thu, 28 Jan 2010 00:32:32 -0800 (PST)
From: Steve VanDeBogart <vandebo-lkml@NerdBox.Net>
Subject: Re: [PATCH] fs: add fincore(2) (mincore(2) for file descriptors)
In-Reply-To: <20100128002313.2b94344e.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.1.00.1001280028160.2909@abydos.NerdBox.Net>
References: <20100120215712.GO27212@frostnet.net> <20100126141229.e1a81b29.akpm@linux-foundation.org> <alpine.DEB.1.00.1001272319530.2909@abydos.NerdBox.Net> <20100128002313.2b94344e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Chris Frost <frost@cs.ucla.edu>, Heiko Carstens <heiko.carstens@de.ibm.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Benny Halevy <bhalevy@panasas.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Jan 2010, Andrew Morton wrote:

> On Wed, 27 Jan 2010 23:42:35 -0800 (PST) Steve VanDeBogart <vandebo-lkml@NerdBox.Net> wrote:
>
>>> Is it likely that these changes to SQLite and Gimp would be merged into
>>> the upstream applications?
>>
>> Changes to the GIMP fit nicely into the code structure, so it's feasible
>> to push this kind of optimization upstream.  The changes in SQLite are
>> a bit more focused on the benchmark, but a more general approach is not
>> conceptually difficult.  SQLite may not want the added complexity, but
>> other database may be interested in the performance improvement.
>>
>> Of course, these kernel changes are needed before any application can
>> optimize its IO as we did with libprefetch.
>
> That didn't really answer my question.
>
> If there's someone signed up and motivated to do the hard work of
> getting these changes integrated into the upstream applications then
> that makes us more interested.  If, however it was some weekend
> proof-of-concept hack which shortly dies an instadeath then...  meh,
> not so much.

Sorry I misunderstood.  The maintainer of GraphicsMagick has already
contacted us about making changes similar to our GIMP changes.  So yes,
there is interest in really using these changes.

--
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
