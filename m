Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 262896B008C
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 03:08:58 -0400 (EDT)
Date: Thu, 4 Apr 2013 09:08:56 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: System freezes when RAM is full (64-bit)
Message-ID: <20130404070856.GB29911@dhcp22.suse.cz>
References: <5159DCA0.3080408@gmail.com>
 <20130403121220.GA14388@dhcp22.suse.cz>
 <515CC8E6.3000402@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <515CC8E6.3000402@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Ivan Danov <huhavel@gmail.com>, linux-mm@kvack.org, 1162073@bugs.launchpad.net

On Thu 04-04-13 08:27:18, Simon Jeons wrote:
> On 04/03/2013 08:12 PM, Michal Hocko wrote:
> >On Mon 01-04-13 21:14:40, Ivan Danov wrote:
> >>The system freezes when RAM gets completely full. By using MATLAB, I
> >>can get all 8GB RAM of my laptop full and it immediately freezes,
> >>needing restart using the hardware button.
> >Do you use swap (file/partition)? How big? Could you collect
> >/proc/meminfo and /proc/vmstat (every few seconds)[1]?
> >What does it mean when you say the system freezes? No new processes can
> >be started or desktop environment doesn't react on your input? Do you
> >see anything in the kernel log? OOM killer e.g.
> >In case no new processes could be started what does sysrq+m say when the
> >system is frozen?
> >
> >What is your kernel config?
> >
> >>Other people have
> >>reported the bug at since 2007. It seems that only the 64-bit
> >>version is affected and people have reported that enabling DMA in
> >>BIOS settings solve the problem. However, my laptop lacks such an
> >>option in the BIOS settings, so I am unable to test it. More
> >>information about the bug could be found at:
> >>https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1162073 and
> >>https://bugs.launchpad.net/ubuntu/+source/linux/+bug/159356.
> >>
> >>Best Regards,
> >>Ivan
> >>
> >---
> >[1] E.g. by
> >while true
> >do
> >	STAMP=`date +%s`
> >	cat /proc/meminfo > meminfo.$STAMP
> >	cat /proc/vmscan > meminfo.$STAMP
> 
> s/vmscan/vmstat

Right. Sorry about the typo and thanks for pointing out Simon.

> 
> >	sleep 2s
> >done
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
