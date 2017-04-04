Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0DE446B0038
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 11:07:30 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id n130so47895944ita.15
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 08:07:30 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id z201si13112819itc.72.2017.04.04.08.07.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 08:07:29 -0700 (PDT)
Date: Tue, 4 Apr 2017 10:07:23 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: Add additional consistency check
In-Reply-To: <20170404113022.GC15490@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1704041005570.23420@east.gentwo.org>
References: <20170331164028.GA118828@beast> <20170404113022.GC15490@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 4 Apr 2017, Michal Hocko wrote:

> NAK without a proper changelog. Seriously, we do not blindly apply
> changes from other projects without a deep understanding of all
> consequences.

Functionalitywise this is trivial. A page must be a slab page in order to
be able to determine the slab cache of an object. Its definitely not ok if
the page is not a slab page.

The main issue that may exist here is the adding of overhead to a critical
code path like kfree().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
