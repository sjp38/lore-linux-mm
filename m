Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 27BB66B0256
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 09:54:16 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fy10so52172355pac.1
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 06:54:16 -0800 (PST)
Received: from out11.biz.mail.alibaba.com (out11.biz.mail.alibaba.com. [205.204.114.131])
        by mx.google.com with ESMTP id p90si20388033pfi.232.2016.02.26.06.54.13
        for <linux-mm@kvack.org>;
        Fri, 26 Feb 2016 06:54:14 -0800 (PST)
Message-ID: <56D067E0.2000201@emindsoft.com.cn>
Date: Fri, 26 Feb 2016 22:57:36 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH trivial] include/linux/gfp.h: Improve the coding styles
References: <1456352791-2363-1-git-send-email-chengang@emindsoft.com.cn> <20160225092752.GU2854@techsingularity.net> <56CF1202.2020809@emindsoft.com.cn> <20160225160707.GX2854@techsingularity.net> <56CF8043.1030603@emindsoft.com.cn> <alpine.LNX.2.00.1602252334400.22700@cbobk.fhfr.pm>
In-Reply-To: <alpine.LNX.2.00.1602252334400.22700@cbobk.fhfr.pm>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-kernel@vger.kernel.org, mhocko@suse.cz, hannes@cmpxchg.org, vdavydov@virtuozzo.com, dan.j.williams@intel.com, linux-mm@kvack.org, Chen Gang <gang.chen.5i5j@gmail.com>

On 2/26/16 06:39, Jiri Kosina wrote:
> On Fri, 26 Feb 2016, Chen Gang wrote:
> 
>> git is a tool mainly for analyzing code, but not mainly for normal
>> reading main code.
>>
>> So for me, the coding styles need not consider about git.
> 
> You are mistaken here. It's very helpful when debugging;

For me, 'debugging' is related with debugger (e.g. kdb or kgdb), and
'tracing' is related with dumping log, and code analyzing is related
with "git diff" and "git blame".

And yes, for me, "git diff" and "git blame" is really very helpful for
code analyzing.

>                                                         usually you want 
> to find the commit that introduced particular change, and read its 
> changelog (at least). Having to cross rather pointless changes just adds 
> time (need to restart git-blame with commit~1 as a base) for no really 
> good reason.
> 

That is the reason why I am not quite care about body files, I often use
"git log -p filename", the cleanup code patch has negative effect with
code analyzing (although for me, it should still need to be cleanup).

But in our case, it is for the shared header file:

 - They are often the common base file, the main contents will not be
   changed quite often, and their contents are usually simple enough (
   e.g. gfp.h in our case), they are not often for "code analyzing".

 - But they are quite often read in normal reading ways by programmers
   (e.g. open with normal editors). For normal reading, programmers
   usually care about the contents, not the changes.

 - So for me, the common shared header files need always take care about
   coding styles, and need not consider about code analyzing.

And if we reject this kind of patch (in our case), I guess, that almost
mean: "for the common shared header files, their bad coding styles will
be remain for ever".


Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
