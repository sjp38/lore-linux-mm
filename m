Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 4144D6B0002
	for <linux-mm@kvack.org>; Wed, 15 May 2013 09:41:12 -0400 (EDT)
Date: Wed, 15 May 2013 15:41:10 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V2 0/3] memcg: simply lock of page stat accounting
Message-ID: <20130515134110.GD5455@dhcp22.suse.cz>
References: <1368421410-4795-1-git-send-email-handai.szj@taobao.com>
 <519380FC.1040504@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <519380FC.1040504@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Sha Zhengju <handai.szj@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, hughd@google.com, gthelen@google.com, Sha Zhengju <handai.szj@taobao.com>

On Wed 15-05-13 16:35:08, Konstantin Khlebnikov wrote:
> Sha Zhengju wrote:
> >Hi,
> >
> >This is my second attempt to make memcg page stat lock simpler, the
> >first version: http://www.spinics.net/lists/linux-mm/msg50037.html.
> >
> >In this version I investigate the potential race conditions among
> >page stat, move_account, charge, uncharge and try to prove it race
> >safe of my proposing lock scheme. The first patch is the basis of
> >the patchset, so if I've made some stupid mistake please do not
> >hesitate to point it out.
> 
> I have a provocational question. Who needs these numbers? I mean
> per-cgroup nr_mapped and so on.

Well, I guess it makes some sense to know how much page cache and anon
memory is charged to the group. I am using that to monitor the per-group
memory usage. I can imagine a even better coverage - something
/proc/meminfo like.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
