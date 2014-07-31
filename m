Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id DD63C6B0035
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 12:58:54 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id ft15so3811374pdb.24
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 09:58:54 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id rj6si3308659pdb.130.2014.07.31.09.58.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jul 2014 09:58:53 -0700 (PDT)
Message-ID: <53DA75C5.5010607@zytor.com>
Date: Thu, 31 Jul 2014 09:58:45 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/7] [RESEND][v4] x86: rework tlb range flushing code
References: <20140731154052.C7E7FBC1@viggo.jf.intel.com>
In-Reply-To: <20140731154052.C7E7FBC1@viggo.jf.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/31/2014 08:40 AM, Dave Hansen wrote:
> x86 Maintainers,
> 
> I've sent this a couple of times and resolved all the feedback
> I've received.  It has sign-offs from Mel and Rik.  Could this
> get picked up in to the x86 tree, please?
> 
> Changes from v3:
>  * Include the patch I was using to gather detailed statistics
>    about the length of the ranged TLB flushes
>  * Fix some documentation typos
>  * Add a patch to rework the remote tlb flush code to plumb the
>    tracepoints in easier, and add missing tracepoints
>  * use __print_symbolic() for the human-readable tracepoint
>    descriptions
>  * change an int to bool in patch 1
>  * Specifically call out that we removed itlb vs. dtlb logic
> 
> Changes from v2:
>  * Added a brief comment above the ceiling tunable
>  * Updated the documentation to mention large pages and say
>    "individual flush" instead of invlpg in most cases.
> 
> I've run this through a variety of systems in the LKP harness,
> as well as running it on my desktop for a few days.  I'm yet to
> see an to see if any perfmance regressions (or gains) show up.
> 

Thanks for the resend.  Applied.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
