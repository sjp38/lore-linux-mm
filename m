Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 08A596B006E
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 12:43:00 -0500 (EST)
Received: by iadk27 with SMTP id k27so7929353iad.14
        for <linux-mm@kvack.org>; Mon, 30 Jan 2012 09:43:00 -0800 (PST)
Date: Mon, 30 Jan 2012 09:42:56 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/3] percpu: use ZERO_SIZE_PTR / ZERO_OR_NULL_PTR
Message-ID: <20120130174256.GF3355@google.com>
References: <1327912654-8738-1-git-send-email-dmitry.antipov@linaro.org>
 <20120130171558.GB3355@google.com>
 <alpine.DEB.2.00.1201301121330.28693@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1201301121330.28693@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Dmitry Antipov <dmitry.antipov@linaro.org>, Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, patches@linaro.org, linaro-dev@lists.linaro.org

On Mon, Jan 30, 2012 at 11:22:14AM -0600, Christoph Lameter wrote:
> On Mon, 30 Jan 2012, Tejun Heo wrote:
> 
> > Percpu pointers are in a different address space and using
> > ZERO_SIZE_PTR directly will trigger sparse address space warning.
> > Also, I'm not entirely sure whether 16 is guaranteed to be unused in
> > percpu address space (maybe it is but I don't think we have anything
> > enforcing that).
> 
> We are already checking for NULL on free. So there is a presumption that
> these numbers are unused.

Yes, we probably don't use 16 as valid dynamic address because static
area would be larger than that.  It's just fuzzier than NULL.  And, as
I wrote in another reply, ZERO_SIZE_PTR simply doesn't contribute
anything.  Maybe we can update the allocator to always not use the
lowest 4k for either static or dynamic and add debug code to
translation macros to check for percpu addresses < 4k, but without
such changes ZERO_SIZE_PTR simply doesn't do anything.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
