Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0AFF89000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 02:09:39 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id CA6563EE0BB
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 15:09:36 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AC13E45DEB9
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 15:09:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DE8D45DEB7
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 15:09:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6376D1DB803F
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 15:09:36 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 18F4A1DB8040
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 15:09:36 +0900 (JST)
Date: Wed, 28 Sep 2011 15:08:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V10 5/6] mm: cleancache: update to match akpm frontswap
 feedback
Message-Id: <20110928150841.fbe661fe.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110915213446.GA26406@ca-server1.us.oracle.com>
References: <20110915213446.GA26406@ca-server1.us.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, konrad.wilk@oracle.com, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, chris.mason@oracle.com, sjenning@linux.vnet.ibm.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

On Thu, 15 Sep 2011 14:34:46 -0700
Dan Magenheimer <dan.magenheimer@oracle.com> wrote:

> From: Dan Magenheimer <dan.magenheimer@oracle.com>
> Subject: [PATCH V10 5/6] mm: cleancache: update to match akpm frontswap feedback
	err = sysfs_create_group(mm_kobj, &cleancache_attr_group);
> -#endif /* CONFIG_SYSFS */
> +#ifdef CONFIG_DEBUG_FS
> +	struct dentry *root = debugfs_create_dir("cleancache", NULL);
> +	if (root == NULL)
> +		return -ENXIO;
> +	debugfs_create_u64("succ_gets", S_IRUGO, root, &cleancache_succ_gets);
> +	debugfs_create_u64("failed_gets", S_IRUGO,
> +				root, &cleancache_failed_gets);
> +	debugfs_create_u64("puts", S_IRUGO, root, &cleancache_puts);
> +	debugfs_create_u64("invalidates", S_IRUGO,
> +				root, &cleancache_invalidates);
> +#endif

No exisiting userlands are affected by this change of flush->invalidates ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
