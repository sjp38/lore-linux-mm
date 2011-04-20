Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 959698D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 07:48:14 -0400 (EDT)
Received: by ewy9 with SMTP id 9so278426ewy.14
        for <linux-mm@kvack.org>; Wed, 20 Apr 2011 04:48:12 -0700 (PDT)
Subject: Re: [PATCH] mm: make read-only accessors take const parameters
From: Artem Bityutskiy <dedekind1@gmail.com>
Reply-To: dedekind1@gmail.com
In-Reply-To: <20110415160701.GE7112@esdhcp04044.research.nokia.com>
References: <1302861377-8048-1-git-send-email-ext-phil.2.carmody@nokia.com>
	 <1302861377-8048-2-git-send-email-ext-phil.2.carmody@nokia.com>
	 <alpine.DEB.2.00.1104150949210.5863@router.home>
	 <20110415160701.GE7112@esdhcp04044.research.nokia.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Apr 2011 14:45:19 +0300
Message-ID: <1303299919.2700.26.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Phil Carmody <ext-phil.2.carmody@nokia.com>
Cc: ext Christoph Lameter <cl@linux.com>, akpm@linux-foundation.org, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 2011-04-15 at 19:07 +0300, Phil Carmody wrote:
> Not in C, alas. As it returns what it's given I wouldn't want it to
> lie
> about the type of what it returns, and some of its clients want it to
> return something writeable. 

I think this little lie is prettier than _ro variants of functions. I do
not think you'll go far with your 'const' quest if you start adding _ro
variants for different core functions, but if you just cast the return
pointer to non-const you might be more successful.

-- 
Best Regards,
Artem Bityutskiy (D?N?N?N?D 1/4  D?D,N?N?N?DoD,D1)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
