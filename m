Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f169.google.com (mail-yw0-f169.google.com [209.85.161.169])
	by kanga.kvack.org (Postfix) with ESMTP id 395BB6B0005
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 21:46:12 -0500 (EST)
Received: by mail-yw0-f169.google.com with SMTP id h129so83691535ywb.1
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 18:46:12 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id a9si5058592ywb.65.2016.02.26.18.46.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 18:46:11 -0800 (PST)
Date: Fri, 26 Feb 2016 21:45:48 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH trivial] include/linux/gfp.h: Improve the coding styles
Message-ID: <20160227024548.GP1215@thunk.org>
References: <1456352791-2363-1-git-send-email-chengang@emindsoft.com.cn>
 <20160225092752.GU2854@techsingularity.net>
 <56CF1202.2020809@emindsoft.com.cn>
 <20160225160707.GX2854@techsingularity.net>
 <56CF8043.1030603@emindsoft.com.cn>
 <CAHz2CGWqndOZQPveuXJaGZQg_YHX+4OmSAB3rtN05RsHk440DA@mail.gmail.com>
 <56D06E8A.9070106@emindsoft.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56D06E8A.9070106@emindsoft.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <chengang@emindsoft.com.cn>
Cc: Jianyu Zhan <nasa4836@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, trivial@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, rientjes@google.com, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, vdavydov@virtuozzo.com, Dan Williams <dan.j.williams@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chen Gang <gang.chen.5i5j@gmail.com>

On Fri, Feb 26, 2016 at 11:26:02PM +0800, Chen Gang wrote:
> > As for coding style, actually IMHO this patch is even _not_ a coding
> > style, more like a code shuffle, indeed.
> > 
> 
> "80 column limitation" is about coding style, I guess, all of us agree
> with it.

No, it's been accepted that checkpatch requiring people to reformat
code to within be 80 columns limitation was actively harmful, and it
no longer does that.

Worse, it now complains when you split a printf string across lines,
so there were patches that split a string across multiple lines to
make checkpatch shut up.  And now there are patches that join the
string back together.

And if you now start submitting patches to split them up again because
you think the 80 column restriction is so darned important, that would
be even ***more*** code churn.

Which is one of the reasons why some of us aren't terribly happy with
people who start running checkpatch -file on other people's code and
start submitting patches, either through the trivial patch portal or
not.

Mel, as an MM developer, has already NACK'ed the patch, which means
you should not send the patch to **any** upstream maintainer for
inclusion.

						- Ted
						

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
