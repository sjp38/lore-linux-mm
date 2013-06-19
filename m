Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 908076B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 06:05:50 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jc3so2269558bkc.14
        for <linux-mm@kvack.org>; Wed, 19 Jun 2013 03:05:48 -0700 (PDT)
Date: Wed, 19 Jun 2013 12:05:45 +0200
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: Re: [Part1 PATCH v5 00/22] x86, ACPI, numa: Parse numa info earlier
Message-ID: <20130619100544.GB4545@dhcp-192-168-178-175.profitbricks.localdomain>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
 <20130618171036.GD4553@dhcp-192-168-178-175.profitbricks.localdomain>
 <CAE9FiQW2CMfNOTNM1MRCZo-ZQuQgj=JQtXLZ3eUxF7dQ8qukTA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAE9FiQW2CMfNOTNM1MRCZo-ZQuQgj=JQtXLZ3eUxF7dQ8qukTA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Thomas Renninger <trenn@suse.de>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, Prarit Bhargava <prarit@redhat.com>, the arch/x86 maintainers <x86@kernel.org>, linux-doc@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Tue, Jun 18, 2013 at 01:19:12PM -0700, Yinghai Lu wrote:
> On Tue, Jun 18, 2013 at 10:10 AM, Vasilis Liaskovitis
> <vasilis.liaskovitis@profitbricks.com> wrote:
> >> could be found at:
> >>         git://git.kernel.org/pub/scm/linux/kernel/git/yinghai/linux-yinghai.git for-x86-mm
> >>
> >> and it is based on today's Linus tree.
> >>
> >
> > Has this patchset been tested on various numa configs?
> > I am using linux-next next-20130607 + part1 with qemu/kvm/seabios VMs. The kernel
> > boots successfully in many numa configs but while trying different memory sizes
> > for a 2 numa node VM, I noticed that booting does not complete in all cases
> > (bootup screen appears to hang but there is no output indicating an early panic)
> >
> > node0   node1    boots
> > 1G      1G       yes
> > 1G      2G       yes
> > 1G      0.5G     yes
> > 3G      2.5G     yes
> > 3G      3G       yes
> > 4G      0G       yes
> > 4G      4G       yes
> > 1.5G    1G       no
> > 2G      1G       no
> > 2G      2G       no
> > 2.5G    2G       no
> > 2.5G    2.5G     no
> >
> > linux-next next-20130607 boots al of these configs fine.
> >
> > Looks odd, perhaps I have something wrong in my setup or maybe there is a
> > seabios/qemu interaction with this patchset. I will update if I find something.
> 
> just tried 2g/2g, and it works on qemu-kvm:

thanks for testing. If you can also share qemu/seabios versions you use (release
or git commits), that would be helpful.

this is most likely some error on my setup, I 'll let you know if I conclude
otherwise.

thanks,

- Vasilis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
