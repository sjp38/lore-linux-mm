Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A010D900137
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 11:07:17 -0400 (EDT)
Received: by bkbzs2 with SMTP id zs2so2157522bkb.14
        for <linux-mm@kvack.org>; Mon, 12 Sep 2011 08:06:44 -0700 (PDT)
Date: Mon, 12 Sep 2011 19:06:30 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC PATCH 2/2] mm: restrict access to /proc/slabinfo
Message-ID: <20110912150630.GE25367@sun>
References: <20110910164001.GA2342@albatros>
 <20110910164134.GA2442@albatros>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110910164134.GA2442@albatros>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: kernel-hardening@lists.openwall.com, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Sep 10, 2011 at 08:41:34PM +0400, Vasiliy Kulikov wrote:
> Historically /proc/slabinfo has 0444 permissions and is accessible to
> the world.  slabinfo contains rather private information related both to
> the kernel and userspace tasks.  Depending on the situation, it might
> reveal either private information per se or information useful to make
> another targeted attack.  Some examples of what can be learned by
> reading/watching for /proc/slabinfo entries:
> 
...

Since this file is controversy point, probably its permissions might be
configurable via setup option?

	Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
