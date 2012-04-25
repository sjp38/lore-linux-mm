Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 1012C6B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 18:28:25 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so2474459pbc.14
        for <linux-mm@kvack.org>; Wed, 25 Apr 2012 15:28:24 -0700 (PDT)
Date: Wed, 25 Apr 2012 15:28:19 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [BUG]memblock: fix overflow of array index
Message-ID: <20120425222819.GF8989@google.com>
References: <CAHnt0GXW-pyOUuBLB1n6qBP4WNGpET9er_HbJ29s5j5DE1xAdA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHnt0GXW-pyOUuBLB1n6qBP4WNGpET9er_HbJ29s5j5DE1xAdA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Teoh <htmldeveloper@gmail.com>
Cc: linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org

On Wed, Apr 25, 2012 at 04:30:19PM +0800, Peter Teoh wrote:
> Fixing the mismatch in signed and unsigned type assignment, which
> potentially can lead to integer overflow bug.
> 
> Thanks.
> 
> Reviewed-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Peter Teoh <htmldeveloper@gmail.com>

All indexes in memblock are integers.  Changing that particular one to
unsigned int doesn't fix anything.  I think it just makes things more
confusing.  If there ever are cases w/ more then 2G memblocks, we're
going for 64bit not unsigned.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
