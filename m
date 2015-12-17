Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id B3D024402ED
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 14:46:12 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id l126so36820939wml.1
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 11:46:12 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id qp7si7108194wjc.3.2015.12.17.11.46.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Dec 2015 11:46:11 -0800 (PST)
Date: Thu, 17 Dec 2015 14:45:45 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v3] mm: Export {__}get_nr_swap_pages()
Message-ID: <20151217194545.GA27852@cmpxchg.org>
References: <20151208112225.GB25800@dhcp22.suse.cz>
 <1450376144-32792-1-git-send-email-david.s.gordon@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1450376144-32792-1-git-send-email-david.s.gordon@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Gordon <david.s.gordon@intel.com>
Cc: intel-gfx@lists.freedesktop.org, Chris Wilson <chris@chris-wilson.co.uk>, "Goel, Akash" <akash.goel@intel.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org

On Thu, Dec 17, 2015 at 06:15:44PM +0000, Dave Gordon wrote:
> Some modules, like i915.ko, use swappable objects and may try to swap
> them out under memory pressure (via the shrinker). Before doing so,
> they want to check using get_nr_swap_pages() to see if any swap space
> is available as otherwise they will waste time purging the object from
> the device without recovering any memory for the system. This requires
> the kernel function get_nr_swap_pages() to be exported to the modules.
> 
> The current implementation of this function is as a static inline
> inside the header file swap.h>; this doesn't work when compiled in
> a module, as the necessary global data is not visible. The original
> proposed solution was to export the kernel global variable to modules,
> but this was considered poor practice as it exposed more than necessary,
> and in an uncontrolled fashion. Another idea was to turn it into a real
> (non-inline) function; however this was considered to unnecessarily add
> overhead for users within the base kernel.
> 
> Therefore, to avoid both objections, this patch leaves the base kernel
> implementation unchanged, but adds a separate (read-only) functional
> interface for callers in loadable kernel modules (LKMs). Which definition
> is visible to code depends on the compile-time symbol MODULE, defined
> by the Kbuild system when building an LKM.

I'm sorry, but this is beyond silly. 19 lines of code to fix a
non-existent problem? This lacks any sort of proportionality.

NAK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
