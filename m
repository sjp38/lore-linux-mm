Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 62F9562012A
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 03:55:56 -0400 (EDT)
Subject: RE: scalability investigation: Where can I get your latest patches?
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
In-Reply-To: <F4DF93C7785E2549970341072BC32CD78D8FC01B@irsmsx503.ger.corp.intel.com>
References: <1278579387.2096.889.camel@ymzhang.sh.intel.com>
	 <20100720031201.GC21274@amd>
	 <1280883843.2125.20.camel@ymzhang.sh.intel.com>
	 <F4DF93C7785E2549970341072BC32CD78D8FC01B@irsmsx503.ger.corp.intel.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Wed, 04 Aug 2010 15:58:37 +0800
Message-Id: <1280908717.2125.33.camel@ymzhang.sh.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kleen, Andi" <andi.kleen@intel.com>
Cc: Nick Piggin <npiggin@suse.de>, "alexs.shi@intel.com" <alexs.shi@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-08-04 at 08:21 +0100, Kleen, Andi wrote:
> > Issues:
> > 1) Compiling fails on a couple of file systems, such like
> > CONFIG_ISO9660_FS=y.
> > 2) dbenchthreads has about 50% regression. We connect a JBOD of 12
> > disks to
> > a machine. Start 4 dbench threads per disk.
> > We run the workload under a regular user account. If we run it under
> > root account,
> > we get 22% improvement instead of regression.
> > The root cause is ACL checking. With your patch, do_path_lookup firstly
> > goes through
> > rcu steps which including a exec permission checking. With ACL, the
> > __exec_permission
> > always fails. Then a later nameidata_drop_rcu often fails as dentry-
> > >d_seq is changed.
> 
> I believe the latest version of Nick's patchkit has a likely fix for that.
> 
> http://git.kernel.org/?p=linux/kernel/git/npiggin/linux-npiggin.git;a=commitdiff;h=9edd35f9aeafc8a5e1688b84cf4488a94898ca45

Thanks Andi. The patch has no ext3 part.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
