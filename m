Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 45BF96B0005
	for <linux-mm@kvack.org>; Sat, 27 Feb 2016 19:18:15 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id w128so24946241pfb.2
        for <linux-mm@kvack.org>; Sat, 27 Feb 2016 16:18:15 -0800 (PST)
Received: from us-alimail-mta2.hst.scl.en.alidc.net (mail113-251.mail.alibaba.com. [205.204.113.251])
        by mx.google.com with ESMTP id w13si30739538pas.206.2016.02.27.16.18.13
        for <linux-mm@kvack.org>;
        Sat, 27 Feb 2016 16:18:14 -0800 (PST)
Message-ID: <56D23D94.50707@emindsoft.com.cn>
Date: Sun, 28 Feb 2016 08:21:40 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH trivial] include/linux/gfp.h: Improve the coding styles
References: <1456352791-2363-1-git-send-email-chengang@emindsoft.com.cn> <20160225092752.GU2854@techsingularity.net> <56CF1202.2020809@emindsoft.com.cn> <20160225160707.GX2854@techsingularity.net> <56CF8043.1030603@emindsoft.com.cn> <CAHz2CGWqndOZQPveuXJaGZQg_YHX+4OmSAB3rtN05RsHk440DA@mail.gmail.com> <56D06E8A.9070106@emindsoft.com.cn> <20160227024548.GP1215@thunk.org> <56D1B364.8050209@emindsoft.com.cn> <20160227165301.GA9506@thunk.org>
In-Reply-To: <20160227165301.GA9506@thunk.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Jianyu Zhan <nasa4836@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, trivial@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, rientjes@google.com, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, vdavydov@virtuozzo.com, Dan Williams <dan.j.williams@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chen Gang <gang.chen.5i5j@gmail.com>


On 2/28/16 00:53, Theodore Ts'o wrote:
> On Sat, Feb 27, 2016 at 10:32:04PM +0800, Chen Gang wrote:
>> I don't think so. Of cause NOT the "CODE CHURN". It is not correct to
>> make an early decision during discussing.
> 
> There is no discussion.  If the maintainer has NAK'ed it.  That's the
> end of the dicsussion.  Period.  See:
> 

For me, NAK also needs reasons.

And this issue is about "coding styles issue", I am not quite sure
whether trivial patch maintainer and mm maintainer are also the
maintainer for "coding styles issues".

I guess they are related with this patch, and their NAKs' reason are: mm
and trivial don't care about this coding style issue, is it correct?


> ftp://ftp.kernel.org/pub/linux/kernel/people/rusty/trivial/template-index.html
> 
> Also note the comment from the above:
> 
>    NOTE: This means I'll only take whitespace/indentation fixes from the
>    author or maintainer.

OK, thanks, it is really one proof for us. :-)

I guess, the file above almost means: except whitespace/indentation,
trivial patches don't consider about the coding styles issues. But can
we say coding styles issues are not issues in our kernel? (I guess not)

If we can not say, I guess one of your suggestion is useful (maybe be
as your suggestion): find one suitable member (I guess I am not), run
"checkpatch -file" under "./include", and fix all reported issues.

Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
