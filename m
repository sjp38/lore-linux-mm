Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C204F6B0007
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 08:25:08 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p10so797271pfl.22
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 05:25:08 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 1-v6si1078659plu.127.2018.04.11.05.25.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Apr 2018 05:25:07 -0700 (PDT)
From: "Li, Philip" <philip.li@intel.com>
Subject: RE: [kbuild-all] [memcg:since-4.16 207/224]
 arch/tile/mm/mmap.c:53:6: error: conflicting types for
 'arch_pick_mmap_layout'
Date: Wed, 11 Apr 2018 12:25:03 +0000
Message-ID: <831EE4E5E37DCC428EB295A351E662494CAA60E6@shsmsx102.ccr.corp.intel.com>
References: <201804111943.GtB7X93z%fengguang.wu@intel.com>
 <20180411113349.GI23400@dhcp22.suse.cz>
In-Reply-To: <20180411113349.GI23400@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, lkp <lkp@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, "kbuild-all@01.org" <kbuild-all@01.org>

> On Wed 11-04-18 19:16:50, kbuild test robot wrote:
> > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git s=
ince-4.16
> > head:   e5edc6faef45baae632fc4c76096a2ab69145c11
> > commit: a18ed29e39bde6c1aaf0fb449732ba8423bc5964 [207/224] exec: pass
> stack rlimit into mm layout functions
> > config: tile-tilegx_defconfig (attached as .config)
> > compiler: tilegx-linux-gcc (GCC) 7.2.0
> > reproduce:
> >         wget https://raw.githubusercontent.com/intel/lkp-
> tests/master/sbin/make.cross -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         git checkout a18ed29e39bde6c1aaf0fb449732ba8423bc5964
> >         # save the attached .config to linux build tree
> >         make.cross ARCH=3Dtile
> >
> > All errors (new ones prefixed by >>):
> >
> > >> arch/tile/mm/mmap.c:53:6: error: conflicting types for
> 'arch_pick_mmap_layout'
> >     void arch_pick_mmap_layout(struct mm_struct *mm)
>=20
> Isn't tile dead? Does it make any sense to compile test it?
thanks for feedback, we will look into this and remove the non-supported ar=
chs.

> --
> Michal Hocko
> SUSE Labs
> _______________________________________________
> kbuild-all mailing list
> kbuild-all@lists.01.org
> https://lists.01.org/mailman/listinfo/kbuild-all
