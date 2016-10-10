Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6142D6B0069
	for <linux-mm@kvack.org>; Mon, 10 Oct 2016 09:55:14 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id k64so142005704itb.5
        for <linux-mm@kvack.org>; Mon, 10 Oct 2016 06:55:14 -0700 (PDT)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id y67si37145663ioi.15.2016.10.10.06.55.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Oct 2016 06:55:13 -0700 (PDT)
Date: Mon, 10 Oct 2016 08:55:13 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 0/1] man/set_mempolicy.2,mbind.2: add MPOL_LOCAL NUMA
 memory policy documentation
In-Reply-To: <20161009185601.3310-1-kwapulinski.piotr@gmail.com>
Message-ID: <alpine.DEB.2.20.1610100854001.27158@east.gentwo.org>
References: <alpine.DEB.2.20.1610040333050.10814@east.gentwo.org> <20161009185601.3310-1-kwapulinski.piotr@gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Cc: mtk.manpages@gmail.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, rientjes@google.com, mhocko@kernel.org, mgorman@techsingularity.net, liangchen.linux@gmail.com, nzimmer@sgi.com, a.p.zijlstra@chello.nl, riel@redhat.com, lee.schermerhorn@hp.com, jmarchan@redhat.com, joe@perches.com, corbet@lwn.net, iamyooon@gmail.com, n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-man@vger.kernel.org, akpm@linux-foundation.org, linux-doc@vger.kernel.org, linux-api@vger.kernel.org

On Sun, 9 Oct 2016, Piotr Kwapulinski wrote:

> +arguments must specify the empty set. If the "local node" is low
> +on free memory the kernel will try to allocate memory from other
> +nodes. The kernel will allocate memory from the "local node"
> +whenever the memory for this node will be released. If the

"whenever memory for this node is available"?

Otherwise

Reviewed-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
