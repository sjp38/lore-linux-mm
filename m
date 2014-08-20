Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 13BD76B0035
	for <linux-mm@kvack.org>; Tue, 19 Aug 2014 23:32:31 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id pv20so6729891lab.29
        for <linux-mm@kvack.org>; Tue, 19 Aug 2014 20:32:31 -0700 (PDT)
Received: from mail-lb0-x233.google.com (mail-lb0-x233.google.com [2a00:1450:4010:c04::233])
        by mx.google.com with ESMTPS id we8si32520340lbb.2.2014.08.19.20.32.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 19 Aug 2014 20:32:30 -0700 (PDT)
Received: by mail-lb0-f179.google.com with SMTP id v6so6201310lbi.38
        for <linux-mm@kvack.org>; Tue, 19 Aug 2014 20:32:29 -0700 (PDT)
Message-ID: <1408505546.5540.25.camel@marge.simpson.net>
Subject: Re: [PATCH] [RFC] TAINT_PERFORMANCE
From: Mike Galbraith <umgwanakikbuti@gmail.com>
Date: Wed, 20 Aug 2014 05:32:26 +0200
In-Reply-To: <20140819222621.GA32690@node.dhcp.inet.fi>
References: <20140819212604.6C94DF09@viggo.jf.intel.com>
	 <20140819222621.GA32690@node.dhcp.inet.fi>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com, peterz@infradead.org, mingo@redhat.com, ak@linux.intel.com, tim.c.chen@linux.intel.com, akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, linux-mm@kvack.org

On Wed, 2014-08-20 at 01:26 +0300, Kirill A. Shutemov wrote: 
> On Tue, Aug 19, 2014 at 02:26:04PM -0700, Dave Hansen wrote:

> > +	TAINT_PERF_IF(SCHEDSTATS);
> 
> Is SCHEDSTATS really harmful?

If your config is minimalist, a tad.  If your config is.. Rubenesque
(distro), you probably won't notice the extra beauty.

> It's enabled in some distro kernels.
> At least in Arch:
> 
> https://projects.archlinux.org/svntogit/packages.git/tree/trunk/config.x86_64?h=packages/linux

Ditto for SUSE.

-Mike


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
