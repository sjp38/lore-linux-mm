Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id A47366B0257
	for <linux-mm@kvack.org>; Sun, 15 Nov 2015 09:13:34 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so147084366pac.3
        for <linux-mm@kvack.org>; Sun, 15 Nov 2015 06:13:34 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id tx3si43416679pbc.224.2015.11.15.06.13.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 15 Nov 2015 06:13:33 -0800 (PST)
Subject: Re: memory reclaim problems on fs usage
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201511102313.36685.arekm@maven.pl>
	<201511142140.38245.arekm@maven.pl>
	<201511151135.JGD81717.OFOOSMFJFQHVtL@I-love.SAKURA.ne.jp>
	<201511151229.23312.arekm@maven.pl>
In-Reply-To: <201511151229.23312.arekm@maven.pl>
Message-Id: <201511152313.IJI23764.OHVFJFMSFOtOLQ@I-love.SAKURA.ne.jp>
Date: Sun, 15 Nov 2015 23:13:23 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arekm@maven.pl
Cc: htejun@gmail.com, cl@linux.com, mhocko@suse.com, linux-mm@kvack.org, xfs@oss.sgi.com

Arkadiusz Miskiewicz wrote:
> On Sunday 15 of November 2015, Tetsuo Handa wrote:
> > I think that the vmstat statistics now have correct values.
> > 
> > > But are these patches solving the problem or just hiding it?
> > 
> > Excuse me but I can't judge.
> >
> > If you are interested in monitoring how vmstat statistics are changing
> > under stalled condition, you can try below patch.
> 
> 
> Here is log with this and all previous patches applied:
> http://ixion.pld-linux.org/~arekm/log-mm-5.txt.gz

Regarding "Node 0 Normal" (min:7104kB low:8880kB high:10656kB),
all free: values look sane to me. I think that your problem was solved.

$ grep "Normal free:" log-mm-5.txt | cut -b 44- | awk -F' ' ' { print $4 } ' | cut -b 6- | sort -g
8608kB
8636kB
8920kB
8920kB
8952kB
8968kB
8980kB
(...snipped...)
215364kB
290068kB
290428kB
291176kB
292836kB
303992kB
306468kB
318080kB
319548kB

$ grep "Normal free:" log-mm-1.txt | cut -b 44- | awk -F' ' ' { print $4 } ' | cut -b 6- | sort -g
0kB
40kB
128kB
128kB
128kB
128kB
128kB
128kB
128kB
128kB
(...snipped...)
412kB
616kB
1268kB
1544kB
1696kB
2756kB
2756kB
2756kB
2756kB
2756kB
2756kB
2756kB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
