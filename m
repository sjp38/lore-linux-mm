Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id DA5826B0005
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 20:48:24 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so5093112pbc.0
        for <linux-mm@kvack.org>; Wed, 23 Jan 2013 17:48:24 -0800 (PST)
Message-ID: <1358992092.3351.10.camel@kernel>
Subject: Re: [PATCH Bug fix 0/5] Bug fix for physical memory hot-remove.
From: Simon Jeons <simon.jeons@gmail.com>
Date: Wed, 23 Jan 2013 19:48:12 -0600
In-Reply-To: <51009003.5020901@cn.fujitsu.com>
References: <1358854984-6073-1-git-send-email-tangchen@cn.fujitsu.com>
	  <1358944171.3351.1.camel@kernel> <50FFE2FC.9030401@cn.fujitsu.com>
	 <1358987715.3351.3.camel@kernel> <51009003.5020901@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, jiang.liu@huawei.com, julian.calaby@gmail.com, sfr@canb.auug.org.au, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org

On Thu, 2013-01-24 at 09:36 +0800, Tang Chen wrote:
> On 01/24/2013 08:35 AM, Simon Jeons wrote:
> > On Wed, 2013-01-23 at 21:17 +0800, Tang Chen wrote:
> >> On 01/23/2013 08:29 PM, Simon Jeons wrote:
> >>> Hi Tang,
> >>>
> >>> I remember your big physical memory hot-remove patchset has already
> >>> merged by Andrew, but where I can find it? Could you give me git tree
> >>> address?
> >>
> >> Hi Simon,
> >>
> >> You can find all the physical memory hot-remove patches and related bugfix
> >> patches from the following url:
> >>
> >> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git akpm
> >
> > ~/linux-next$ git remote -v
> > origin git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
> > (fetch)
> > origin git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
> > (push)
> > ~/linux-next$ git branch
> > * akpm
> >    master
> > ~/linux-next$ wc -l mm/memory_hotplug.c
> > 1173 mm/memory_hotplug.c
> >
> > I still can't find it. :(
> 
> Hi Simon,
> 
> It's weird, in my akpm git log, I can find the following commit.
> 
> commit deed0460e01b3968f2cf46fb94851936535b7e0d
> Author: Tang Chen <tangchen@cn.fujitsu.com>
> Date:   Sat Jan 19 11:07:13 2013 +1100
> 
>      memory-hotplug: do not allocate pgdat if it was not freed when offline.
> 
> And there are 15 related patches following it. And above it, there are 
> some more related bugfix
> from me and Andrew. They are all in -mm tree.
> 
> This is what I did:
> 
>    $ git remote add next 
> http://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
>    $ git remote update next
>    $ git checkout -b next-akpm remotes/next/akpm
> 
> Please pull your tree and try again. :)

Got it. Thanks! :)

> 
> Thanks. :)
> 
> 
> >
> >>
> >>
> >> Thanks. :)
> >>
> >> --
> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> the body to majordomo@kvack.org.  For more info on Linux MM,
> >> see: http://www.linux-mm.org/ .
> >> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>
> >
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
