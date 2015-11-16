Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 837786B0038
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 11:15:23 -0500 (EST)
Received: by wmww144 with SMTP id w144so126326478wmw.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 08:15:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n206si26582979wma.29.2015.11.16.08.15.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Nov 2015 08:15:19 -0800 (PST)
Date: Mon, 16 Nov 2015 17:15:18 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memory reclaim problems on fs usage
Message-ID: <20151116161518.GI14116@dhcp22.suse.cz>
References: <201511102313.36685.arekm@maven.pl>
 <201511151229.23312.arekm@maven.pl>
 <201511152313.IJI23764.OHVFJFMSFOtOLQ@I-love.SAKURA.ne.jp>
 <201511151549.35299.arekm@maven.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <201511151549.35299.arekm@maven.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arkadiusz =?utf-8?Q?Mi=C5=9Bkiewicz?= <arekm@maven.pl>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, htejun@gmail.com, cl@linux.com, linux-mm@kvack.org, xfs@oss.sgi.com

On Sun 15-11-15 15:49:35, Arkadiusz MiA?kiewicz wrote:
> On Sunday 15 of November 2015, Tetsuo Handa wrote:
> > Arkadiusz Miskiewicz wrote:
> > > On Sunday 15 of November 2015, Tetsuo Handa wrote:
> > > > I think that the vmstat statistics now have correct values.
> > > > 
> > > > > But are these patches solving the problem or just hiding it?
> > > > 
> > > > Excuse me but I can't judge.
> > > > 
> > > > If you are interested in monitoring how vmstat statistics are changing
> > > > under stalled condition, you can try below patch.
> > > 
> > > Here is log with this and all previous patches applied:
> > > http://ixion.pld-linux.org/~arekm/log-mm-5.txt.gz
> > 
> > Regarding "Node 0 Normal" (min:7104kB low:8880kB high:10656kB),
> > all free: values look sane to me. I think that your problem was solved.
> 
> Great, thanks!
> 
> Will all (or part) of these patches
> 
> http://sprunge.us/GYBb

Migrate reserves are not a stable material I am afraid. "vmstat:
explicitly schedule per-cpu work on the CPU we need it to run on"
was not marked for stable either but I am not sure why it should make
any difference for your load. I understand that testing this is really
tedious but it would be better to know which of the patches actually
made a difference.

> http://sprunge.us/XWUX (after it gets merged)

Yes I plan to mark this one for stable.
 
> be pushed to stable@ or are too risky for stable ?
> 
> > 
> > $ grep "Normal free:" log-mm-5.txt | cut -b 44- | awk -F' ' ' { print $4 }
> > ' | cut -b 6- | sort -g 8608kB
> > 8636kB
> > 8920kB
> > 8920kB
> > 8952kB
> > 8968kB
> > 8980kB
> > (...snipped...)
> > 215364kB
> > 290068kB
> > 290428kB
> > 291176kB
> > 292836kB
> > 303992kB
> > 306468kB
> > 318080kB
> > 319548kB
> > 
> > $ grep "Normal free:" log-mm-1.txt | cut -b 44- | awk -F' ' ' { print $4 }
> > ' | cut -b 6- | sort -g 0kB
> > 40kB
> > 128kB
> > 128kB
> > 128kB
> > 128kB
> > 128kB
> > 128kB
> > 128kB
> > 128kB
> > (...snipped...)
> > 412kB
> > 616kB
> > 1268kB
> > 1544kB
> > 1696kB
> > 2756kB
> > 2756kB
> > 2756kB
> > 2756kB
> > 2756kB
> > 2756kB
> > 2756kB
> 
> 
> -- 
> Arkadiusz MiA?kiewicz, arekm / ( maven.pl | pld-linux.org )

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
