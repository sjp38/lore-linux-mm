Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id D91506B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 19:15:57 -0500 (EST)
Received: by mail-ob0-f177.google.com with SMTP id wo20so3271763obc.36
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 16:15:57 -0800 (PST)
Received: from g2t2354.austin.hp.com (g2t2354.austin.hp.com. [15.217.128.53])
        by mx.google.com with ESMTPS id pp9si7102951obc.37.2014.03.06.16.15.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Mar 2014 16:15:56 -0800 (PST)
Message-ID: <1394151350.2555.2.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 0/7] x86: rework tlb range flushing code
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Thu, 06 Mar 2014 16:15:50 -0800
In-Reply-To: <20140306004519.BBD70A1A@viggo.jf.intel.com>
References: <20140306004519.BBD70A1A@viggo.jf.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, ak@linux.intel.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, alex.shi@linaro.org, x86@kernel.org, linux-mm@kvack.org

On Wed, 2014-03-05 at 16:45 -0800, Dave Hansen wrote:
> Reposting with an instrumentation patch, and a few minor tweaks.
> I'd love some more eyeballs on this, but I think it's ready for
> -mm.
> 
> I'm having it run through the LKP harness to see if any perfmance
> regressions (or gains) show up.

fwiw I pounded these on a 80 core Westmere with my usual aim7 stuff for
most of the morning and didn't run into anything unusual or performance
differences.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
