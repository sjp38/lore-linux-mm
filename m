Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9BA2762012A
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 03:21:53 -0400 (EDT)
From: "Kleen, Andi" <andi.kleen@intel.com>
Date: Wed, 4 Aug 2010 08:21:30 +0100
Subject: RE: scalability investigation: Where can I get your latest patches?
Message-ID: <F4DF93C7785E2549970341072BC32CD78D8FC01B@irsmsx503.ger.corp.intel.com>
References: <1278579387.2096.889.camel@ymzhang.sh.intel.com>
	 <20100720031201.GC21274@amd> <1280883843.2125.20.camel@ymzhang.sh.intel.com>
In-Reply-To: <1280883843.2125.20.camel@ymzhang.sh.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Nick Piggin <npiggin@suse.de>
Cc: "alexs.shi@intel.com" <alexs.shi@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> Issues:
> 1) Compiling fails on a couple of file systems, such like
> CONFIG_ISO9660_FS=3Dy.
> 2) dbenchthreads has about 50% regression. We connect a JBOD of 12
> disks to
> a machine. Start 4 dbench threads per disk.
> We run the workload under a regular user account. If we run it under
> root account,
> we get 22% improvement instead of regression.
> The root cause is ACL checking. With your patch, do_path_lookup firstly
> goes through
> rcu steps which including a exec permission checking. With ACL, the
> __exec_permission
> always fails. Then a later nameidata_drop_rcu often fails as dentry-
> >d_seq is changed.

I believe the latest version of Nick's patchkit has a likely fix for that.

http://git.kernel.org/?p=3Dlinux/kernel/git/npiggin/linux-npiggin.git;a=3Dc=
ommitdiff;h=3D9edd35f9aeafc8a5e1688b84cf4488a94898ca45

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
