Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id B24146B0253
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 15:55:23 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id s30so60336941ioi.0
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 12:55:23 -0700 (PDT)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id n124si6576342ite.74.2016.10.12.12.55.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 12:55:22 -0700 (PDT)
Date: Wed, 12 Oct 2016 14:55:23 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 0/1] man/set_mempolicy.2,mbind.2: add MPOL_LOCAL NUMA
 memory policy documentation
In-Reply-To: <20161012155309.GA2706@home>
Message-ID: <alpine.DEB.2.20.1610121455040.11069@east.gentwo.org>
References: <alpine.DEB.2.20.1610100854001.27158@east.gentwo.org> <20161010162310.2463-1-kwapulinski.piotr@gmail.com> <4d816fee-4690-2ed7-7faa-c437e67cfbf5@gmail.com> <20161012155309.GA2706@home>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Cc: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, kirill.shutemov@linux.intel.com, vbabka@suse.cz, rientjes@google.com, mhocko@kernel.org, mgorman@techsingularity.net, liangchen.linux@gmail.com, nzimmer@sgi.com, a.p.zijlstra@chello.nl, riel@redhat.com, lee.schermerhorn@hp.com, jmarchan@redhat.com, joe@perches.com, corbet@lwn.net, iamyooon@gmail.com, n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-man@vger.kernel.org, akpm@linux-foundation.org, linux-doc@vger.kernel.org, linux-api@vger.kernel.org

On Wed, 12 Oct 2016, Piotr Kwapulinski wrote:

> That's right. This could be "local allocation" or any other memory policy.

Correct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
