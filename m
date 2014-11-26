Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6259F6B0069
	for <linux-mm@kvack.org>; Wed, 26 Nov 2014 15:49:39 -0500 (EST)
Received: by mail-ie0-f181.google.com with SMTP id tp5so3370988ieb.40
        for <linux-mm@kvack.org>; Wed, 26 Nov 2014 12:49:39 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h12si4203514ici.1.2014.11.26.12.49.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Nov 2014 12:49:38 -0800 (PST)
Date: Wed, 26 Nov 2014 12:49:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 3/8] mm/debug-pagealloc: make debug-pagealloc
 boottime configurable
Message-Id: <20141126124936.56cc901e13f27927d7b42aaf@linux-foundation.org>
In-Reply-To: <20141124234237.GA7824@js1304-P5Q-DELUXE>
References: <1416816926-7756-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1416816926-7756-4-git-send-email-iamjoonsoo.kim@lge.com>
	<20141124145542.08b97076.akpm@linux-foundation.org>
	<20141124234237.GA7824@js1304-P5Q-DELUXE>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave@sr71.net>, Michal Nazarewicz <mina86@mina86.com>, Jungsoo Son <jungsoo.son@lge.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 25 Nov 2014 08:42:37 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> On Mon, Nov 24, 2014 at 02:55:42PM -0800, Andrew Morton wrote:
> > On Mon, 24 Nov 2014 17:15:21 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > 
> > > Now, we have prepared to avoid using debug-pagealloc in boottime. So
> > > introduce new kernel-parameter to disable debug-pagealloc in boottime,
> > > and makes related functions to be disabled in this case.
> > > 
> > > Only non-intuitive part is change of guard page functions. Because
> > > guard page is effective only if debug-pagealloc is enabled, turning off
> > > according to debug-pagealloc is reasonable thing to do.
> > > 
> > > ...
> > >
> > > --- a/Documentation/kernel-parameters.txt
> > > +++ b/Documentation/kernel-parameters.txt
> > > @@ -858,6 +858,14 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
> > >  			causing system reset or hang due to sending
> > >  			INIT from AP to BSP.
> > >  
> > > +	disable_debug_pagealloc
> > > +			[KNL] When CONFIG_DEBUG_PAGEALLOC is set, this
> > > +			parameter allows user to disable it at boot time.
> > > +			With this parameter, we can avoid allocating huge
> > > +			chunk of memory for debug pagealloc and then
> > > +			the system will work mostly same with the kernel
> > > +			built without CONFIG_DEBUG_PAGEALLOC.
> > > +
> > 
> > Weren't we going to make this default to "off", require a boot option
> > to turn debug_pagealloc on?
> 
> Hello, Andrew.
> 
> I'm afraid that changing default to "off" confuses some old users.
> They would expect that it is default "on". But, it is just debug
> feature, so, it may be no problem. If you prefer to change default, I
> will rework this patch. Please let me know your decision.

I suspect the number of "old users" is one ;)

I think it would be better to default to off - that's the typical
behaviour for debug features, for good reasons.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
