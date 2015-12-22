Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2FC536B0255
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 11:25:03 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id ph11so63668802igc.1
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 08:25:03 -0800 (PST)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id i9si34618620igm.4.2015.12.22.08.25.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 22 Dec 2015 08:25:02 -0800 (PST)
Date: Tue, 22 Dec 2015 10:25:00 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [kernel-hardening] [RFC][PATCH 6/7] mm: Add Kconfig option for
 slab sanitization
In-Reply-To: <567964F3.2020402@intel.com>
Message-ID: <alpine.DEB.2.20.1512221023550.2748@east.gentwo.org>
References: <1450755641-7856-1-git-send-email-laura@labbott.name> <1450755641-7856-7-git-send-email-laura@labbott.name> <567964F3.2020402@intel.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: kernel-hardening@lists.openwall.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <laura@labbott.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>

On Tue, 22 Dec 2015, Dave Hansen wrote:

> On 12/21/2015 07:40 PM, Laura Abbott wrote:
> > +	  The tradeoff is performance impact. The noticible impact can vary
> > +	  and you are advised to test this feature on your expected workload
> > +	  before deploying it
>
> What if instead of writing SLAB_MEMORY_SANITIZE_VALUE, we wrote 0's?
> That still destroys the information, but it has the positive effect of
> allowing a kzalloc() call to avoid zeroing the slab object.  It might
> mitigate some of the performance impact.

We already write zeros in many cases or the object is initialized in a
different. No one really wants an uninitialized object. The problem may be
that a freed object is having its old content until reused. Which is
something that poisoning deals with.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
