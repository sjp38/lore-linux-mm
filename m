Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f205.google.com (mail-ob0-f205.google.com [209.85.214.205])
	by kanga.kvack.org (Postfix) with ESMTP id 6504B6B0036
	for <linux-mm@kvack.org>; Sat, 11 Jan 2014 12:23:01 -0500 (EST)
Received: by mail-ob0-f205.google.com with SMTP id wo20so99118obc.8
        for <linux-mm@kvack.org>; Sat, 11 Jan 2014 09:23:01 -0800 (PST)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id g70si10229632yhd.143.2014.01.10.15.43.35
        for <linux-mm@kvack.org>;
        Fri, 10 Jan 2014 15:43:36 -0800 (PST)
Message-ID: <52D0854F.5060102@sr71.net>
Date: Fri, 10 Jan 2014 15:42:07 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 0/9] re-shrink 'struct page' when SLUB is on.
References: <20140103180147.6566F7C1@viggo.jf.intel.com>	<20140103141816.20ef2a24c8adffae040e53dc@linux-foundation.org>	<20140106043237.GE696@lge.com>	<52D05D90.3060809@sr71.net> <20140110153913.844e84755256afd271371493@linux-foundation.org>
In-Reply-To: <20140110153913.844e84755256afd271371493@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, penberg@kernel.org, cl@linux-foundation.org

On 01/10/2014 03:39 PM, Andrew Morton wrote:
>> I tested 4 cases, all of these on the "cache-cold kfree()" case.  The
>> first 3 are with vanilla upstream kernel source.  The 4th is patched
>> with my new slub code (all single-threaded):
>>
>> 	http://www.sr71.net/~dave/intel/slub/slub-perf-20140109.png
> 
> So we're converging on the most complex option.  argh.

Yeah, looks that way.

> So all this testing was performed in a VM?  If so, how much is that
> likely to have impacted the results?

Nope, none of it was in a VM.  All the results here are from bare-metal.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
