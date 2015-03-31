Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3599D6B006C
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 20:07:35 -0400 (EDT)
Received: by qcay5 with SMTP id y5so1232355qca.1
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 17:07:35 -0700 (PDT)
Received: from smtp101.biz.mail.bf1.yahoo.com (smtp101.biz.mail.bf1.yahoo.com. [98.139.221.60])
        by mx.google.com with ESMTPS id b90si12057150qgb.50.2015.03.30.17.07.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 30 Mar 2015 17:07:34 -0700 (PDT)
Message-ID: <5519E53B.5040504@schaufler-ca.com>
Date: Mon, 30 Mar 2015 17:07:23 -0700
From: Casey Schaufler <casey@schaufler-ca.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/25] treewide: Use bool function return values of true/false
 not 1/0
References: <cover.1427759009.git.joe@perches.com>
In-Reply-To: <cover.1427759009.git.joe@perches.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvmarm@lists.cs.columbia.edu, kvm@vger.kernel.org, linux-omap@vger.kernel.org, kvm-ppc@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org, linux-ide@vger.kernel.org, kgdb-bugreport@lists.sourceforge.net, linux-mm@kvack.org, linux-pm@vger.kernel.org, netdev@vger.kernel.org, alsa-devel@alsa-project.org, bridge@lists.linux-foundation.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, patches@opensource.wolfsonmicro.com
Cc: linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-scsi@vger.kernel.org, linux-security-module@vger.kernel.org

On 3/30/2015 4:45 PM, Joe Perches wrote:
> Joe Perches (25):
>   arm: Use bool function return values of true/false not 1/0
>   arm64: Use bool function return values of true/false not 1/0
>   hexagon: Use bool function return values of true/false not 1/0
>   ia64: Use bool function return values of true/false not 1/0
>   mips: Use bool function return values of true/false not 1/0
>   powerpc: Use bool function return values of true/false not 1/0
>   s390: Use bool function return values of true/false not 1/0
>   sparc: Use bool function return values of true/false not 1/0
>   tile: Use bool function return values of true/false not 1/0
>   unicore32: Use bool function return values of true/false not 1/0
>   x86: Use bool function return values of true/false not 1/0
>   virtio_console: Use bool function return values of true/false not 1/0
>   csiostor: Use bool function return values of true/false not 1/0
>   dcache: Use bool function return values of true/false not 1/0
>   nfsd: nfs4state: Use bool function return values of true/false not 1/0
>   include/linux: Use bool function return values of true/false not 1/0
>   sound: Use bool function return values of true/false not 1/0
>   rcu: tree_plugin: Use bool function return values of true/false not 1/0
>   sched: Use bool function return values of true/false not 1/0
>   ftrace: Use bool function return values of true/false not 1/0
>   slub: Use bool function return values of true/false not 1/0
>   bridge: Use bool function return values of true/false not 1/0
>   netfilter: Use bool function return values of true/false not 1/0
>   security: Use bool function return values of true/false not 1/0
>   sound: wm5100-tables: Use bool function return values of true/false not 1/0
>
>  arch/arm/include/asm/dma-mapping.h           |  8 ++--
>  arch/arm/include/asm/kvm_emulate.h           |  2 +-
>  arch/arm/mach-omap2/powerdomain.c            | 14 +++---
>  arch/arm64/include/asm/dma-mapping.h         |  2 +-
>  arch/hexagon/include/asm/dma-mapping.h       |  2 +-
>  arch/ia64/include/asm/dma-mapping.h          |  2 +-
>  arch/mips/include/asm/dma-mapping.h          |  2 +-
>  arch/powerpc/include/asm/dcr-native.h        |  2 +-
>  arch/powerpc/include/asm/dma-mapping.h       |  4 +-
>  arch/powerpc/include/asm/kvm_book3s_64.h     |  4 +-
>  arch/powerpc/sysdev/dcr.c                    |  2 +-
>  arch/s390/include/asm/dma-mapping.h          |  2 +-
>  arch/sparc/mm/init_64.c                      |  8 ++--
>  arch/tile/include/asm/dma-mapping.h          |  2 +-
>  arch/unicore32/include/asm/dma-mapping.h     |  2 +-
>  arch/x86/include/asm/archrandom.h            |  2 +-
>  arch/x86/include/asm/dma-mapping.h           |  2 +-
>  arch/x86/include/asm/kvm_para.h              |  2 +-
>  arch/x86/kvm/cpuid.h                         |  2 +-
>  arch/x86/kvm/vmx.c                           | 72 ++++++++++++++--------------
>  drivers/char/virtio_console.c                |  2 +-
>  drivers/scsi/csiostor/csio_scsi.c            |  4 +-
>  fs/dcache.c                                  | 12 ++---
>  fs/nfsd/nfs4state.c                          |  2 +-
>  include/linux/blkdev.h                       |  2 +-
>  include/linux/ide.h                          |  2 +-
>  include/linux/kgdb.h                         |  2 +-
>  include/linux/mfd/db8500-prcmu.h             |  2 +-
>  include/linux/mm.h                           |  2 +-
>  include/linux/power_supply.h                 |  8 ++--
>  include/linux/ssb/ssb_driver_extif.h         |  2 +-
>  include/linux/ssb/ssb_driver_gige.h          | 16 +++----
>  include/sound/soc.h                          |  4 +-
>  kernel/rcu/tree_plugin.h                     |  4 +-
>  kernel/sched/auto_group.h                    |  2 +-
>  kernel/sched/completion.c                    | 16 ++++---
>  kernel/trace/ftrace.c                        | 10 ++--
>  mm/slub.c                                    | 12 ++---
>  net/bridge/br_private.h                      |  2 +-
>  net/ipv4/netfilter/ipt_ah.c                  |  2 +-
>  net/netfilter/ipset/ip_set_hash_ip.c         |  8 ++--
>  net/netfilter/ipset/ip_set_hash_ipmark.c     |  8 ++--
>  net/netfilter/ipset/ip_set_hash_ipport.c     |  8 ++--
>  net/netfilter/ipset/ip_set_hash_ipportip.c   |  8 ++--
>  net/netfilter/ipset/ip_set_hash_ipportnet.c  |  8 ++--
>  net/netfilter/ipset/ip_set_hash_net.c        |  8 ++--
>  net/netfilter/ipset/ip_set_hash_netiface.c   |  8 ++--
>  net/netfilter/ipset/ip_set_hash_netport.c    |  8 ++--
>  net/netfilter/ipset/ip_set_hash_netportnet.c |  8 ++--
>  net/netfilter/xt_connlimit.c                 |  2 +-
>  net/netfilter/xt_hashlimit.c                 |  2 +-
>  net/netfilter/xt_ipcomp.c                    |  2 +-
>  security/apparmor/file.c                     |  8 ++--
>  security/apparmor/policy.c                   | 10 ++--
>  sound/soc/codecs/wm5100-tables.c             | 12 ++---

Why, and why these in particular?

>  55 files changed, 178 insertions(+), 176 deletions(-)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
