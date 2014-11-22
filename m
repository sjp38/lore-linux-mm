Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5692B6B006E
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 19:36:13 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so5895490pab.6
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 16:36:13 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id gv6si11067001pac.208.2014.11.21.16.36.10
        for <linux-mm@kvack.org>;
        Fri, 21 Nov 2014 16:36:12 -0800 (PST)
Date: Fri, 21 Nov 2014 16:36:04 -0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [mmotm:master 108/319] kernel/events/uprobes.c:319:2: error:
 implicit declaration of function 'mem_cgroup_charge_anon'
Message-ID: <20141122003604.GA24535@wfg-t540p.sh.intel.com>
References: <53ab71c4.YGFc6XN+rgscOdCJ%fengguang.wu@intel.com>
 <20140626130223.2db7a085421f594eb1707eb8@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140626130223.2db7a085421f594eb1707eb8@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org

Hi Andrew,

On Thu, Jun 26, 2014 at 01:02:23PM -0700, Andrew Morton wrote:
> On Thu, 26 Jun 2014 09:05:08 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
> 
> > tree:   git://git.cmpxchg.org/linux-mmotm.git master
> > head:   9477ec75947f2cf0fc47e8ab781a5e9171099be2
> > commit: 5c83b35612a2f2894b54d902ac50612cec2e1926 [108/319] mm: memcontrol: rewrite charge API
> > config: i386-randconfig-ha2-0626 (attached as .config)
> > 
> > Note: the mmotm/master HEAD 9477ec75947f2cf0fc47e8ab781a5e9171099be2 builds fine.
> >       It only hurts bisectibility.
> > 
> > All error/warnings:
> > 
> >    kernel/events/uprobes.c: In function 'uprobe_write_opcode':
> > >> kernel/events/uprobes.c:319:2: error: implicit declaration of function 'mem_cgroup_charge_anon' [-Werror=implicit-function-declaration]
> >      if (mem_cgroup_charge_anon(new_page, mm, GFP_KERNEL))
> >      ^
> >    cc1: some warnings being treated as errors
> 
> The next patch mm-memcontrol-rewrite-charge-api-fix-3.patch fixes this
> up.  Is there something I did which fooled the buildbot's
> hey-theres-a-fixup-patch detector?

Git log shows that the next patch is "kernel: uprobes: switch to new
memcg charge protocol" and in fact there is no
mm-memcontrol-rewrite-charge-api-fix-3.patch at the time this git
branch is created:

                        34346b2c memcg: mem_cgroup_charge_statistics needs preempt_disable
fix 2 =>                ac43603 mm: memcontrol: rewrite uncharge API fix 2
fix 1 =>                0d971aa mm: memcontrol: rewrite uncharge API
                        a9f32f2 kernel: uprobes: switch to new memcg charge protocol
first bad commit =>     5c83b35 mm: memcontrol: rewrite charge API

That should explain why the buildbot reported the error out.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
