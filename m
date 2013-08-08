Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id AA6836B0039
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 22:53:43 -0400 (EDT)
Message-ID: <5203081C.8050403@huawei.com>
Date: Thu, 8 Aug 2013 10:53:16 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCHSET cgroup/for-3.12] cgroup: make cgroup_event specific
 to memcg
References: <1375632446-2581-1-git-send-email-tj@kernel.org> <20130805160107.GM10146@dhcp22.suse.cz> <20130805162958.GF19631@mtj.dyndns.org> <20130805191641.GA24003@dhcp22.suse.cz> <20130805194431.GD23751@mtj.dyndns.org> <20130806155804.GC31138@dhcp22.suse.cz> <20130806161509.GB10779@mtj.dyndns.org> <20130807121836.GF8184@dhcp22.suse.cz> <20130807124321.GA27006@htj.dyndns.org> <20130807132613.GH8184@dhcp22.suse.cz> <20130807133645.GE27006@htj.dyndns.org>
In-Reply-To: <20130807133645.GE27006@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, hannes@cmpxchg.org, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

>> If somebody needs a notification interface (and there is no one available
>> right now) then you cannot prevent from such a pointless work anyway...
> 
> I'm gonna add one for freezer state transitions.  It'll be simple
> "this file changed" thing and will probably apply that to at least oom
> and vmpressure.  I'm relatively confident that it's gonna be pretty
> simple and that's gonna be the cgroup event mechanism.
> 

I would like to see this happen. I have a feeling that we're deprecating
features a bit aggressively without providing alternatives.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
