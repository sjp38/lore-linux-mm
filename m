Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id 834306B0005
	for <linux-mm@kvack.org>; Sat, 27 Feb 2016 11:53:16 -0500 (EST)
Received: by mail-yk0-f172.google.com with SMTP id z13so47567818ykd.0
        for <linux-mm@kvack.org>; Sat, 27 Feb 2016 08:53:16 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id m127si5821131ywe.417.2016.02.27.08.53.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Feb 2016 08:53:15 -0800 (PST)
Date: Sat, 27 Feb 2016 11:53:01 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH trivial] include/linux/gfp.h: Improve the coding styles
Message-ID: <20160227165301.GA9506@thunk.org>
References: <1456352791-2363-1-git-send-email-chengang@emindsoft.com.cn>
 <20160225092752.GU2854@techsingularity.net>
 <56CF1202.2020809@emindsoft.com.cn>
 <20160225160707.GX2854@techsingularity.net>
 <56CF8043.1030603@emindsoft.com.cn>
 <CAHz2CGWqndOZQPveuXJaGZQg_YHX+4OmSAB3rtN05RsHk440DA@mail.gmail.com>
 <56D06E8A.9070106@emindsoft.com.cn>
 <20160227024548.GP1215@thunk.org>
 <56D1B364.8050209@emindsoft.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56D1B364.8050209@emindsoft.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <chengang@emindsoft.com.cn>
Cc: Jianyu Zhan <nasa4836@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, trivial@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, rientjes@google.com, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, vdavydov@virtuozzo.com, Dan Williams <dan.j.williams@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chen Gang <gang.chen.5i5j@gmail.com>

On Sat, Feb 27, 2016 at 10:32:04PM +0800, Chen Gang wrote:
> I don't think so. Of cause NOT the "CODE CHURN". It is not correct to
> make an early decision during discussing.

There is no discussion.  If the maintainer has NAK'ed it.  That's the
end of the dicsussion.  Period.  See:

ftp://ftp.kernel.org/pub/linux/kernel/people/rusty/trivial/template-index.html

Also note the comment from the above:

   NOTE: This means I'll only take whitespace/indentation fixes from the
   author or maintainer.

      	   	      	   			       	     - Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
