Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id B492D8D0003
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 16:45:30 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so3200583eaa.14
        for <linux-mm@kvack.org>; Thu, 22 Nov 2012 13:45:29 -0800 (PST)
Date: Thu, 22 Nov 2012 22:45:27 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memory-cgroup bug
Message-ID: <20121122214527.GB20319@dhcp22.suse.cz>
References: <20121121200207.01068046@pobox.sk>
 <50AD713F.9030909@jp.fujitsu.com>
 <20121122103618.79F03818@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121122103618.79F03818@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Thu 22-11-12 10:36:18, azurIt wrote:
[...]
> I can look also to the data of 'freezed' proces if you need it but i
> will have to wait until problem occurs again.
> 
> The main problem is that when this problem happens, it's NOT resolved
> automatically by kernel/OOM and user of cgroup, where it happend, has
> non-working services until i kill his processes by hand. I'm sure
> that all 'freezed' processes are taking very much CPU because also
> server load goes really high - next time i will make a screenshot of
> htop. I really wonder why OOM is __sometimes__ not resolving this
> (it's usually is, only sometimes not).

What does your kernel log says while this is happening. Are there any
memcg OOM messages showing up?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
