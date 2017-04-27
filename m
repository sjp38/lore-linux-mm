Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id A9EE66B02E1
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 08:06:28 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g67so2909065wrd.0
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 05:06:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g14si2518528wrb.231.2017.04.27.05.06.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Apr 2017 05:06:27 -0700 (PDT)
Date: Thu, 27 Apr 2017 14:06:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Add additional consistency check
Message-ID: <20170427120625.GB4785@dhcp22.suse.cz>
References: <20170331164028.GA118828@beast>
 <20170404113022.GC15490@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170404113022.GC15490@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 04-04-17 13:30:22, Michal Hocko wrote:
> On Fri 31-03-17 09:40:28, Kees Cook wrote:
> > As found in PaX, this adds a cheap check on heap consistency, just to
> > notice if things have gotten corrupted in the page lookup.
> >
> > Signed-off-by: Kees Cook <keescook@chromium.org>
> 
> NAK without a proper changelog. Seriously, we do not blindly apply
> changes from other projects without a deep understanding of all
> consequences.

This still seems to be in the mmotm tree
http://www.ozlabs.org/~akpm/mmotm/broken-out/mm-add-additional-consistency-check.patch
I hope we have agreed that this is not the right approach to handle
invalid pointers in kfree and rather go soemthing like
http://lkml.kernel.org/r/20170411141956.GP6729@dhcp22.suse.cz
instead.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
