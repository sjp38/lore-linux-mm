Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 71242900136
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 16:46:20 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8DKM83q031608
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 16:22:08 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8DKkIqg207634
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 16:46:18 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8DKjqim011778
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 14:45:53 -0600
Message-ID: <4E6FC109.5090608@linux.vnet.ibm.com>
Date: Tue, 13 Sep 2011 15:46:01 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH V9 5/6] mm: cleancache: update to match akpm frontswap
 feedback
References: <20110913174106.GA11330@ca-server1.us.oracle.com>
In-Reply-To: <20110913174106.GA11330@ca-server1.us.oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, konrad.wilk@oracle.com, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, chris.mason@oracle.com, kamezawa.hiroyu@jp.fujitsu.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

Hey Dan,

Same typecasting needed here:

mm/cleancache.c: In function ?init_cleancache?:
mm/cleancache.c:214:5: warning: passing argument 4 of ?debugfs_create_size_t? from incompatible pointer type
include/linux/debugfs.h:68:16: note: expected ?size_t *? but argument is of type ?long unsigned int *?
mm/cleancache.c:216:5: warning: passing argument 4 of ?debugfs_create_size_t? from incompatible pointer type
include/linux/debugfs.h:68:16: note: expected ?size_t *? but argument is of type ?long unsigned int *?
mm/cleancache.c:218:5: warning: passing argument 4 of ?debugfs_create_size_t? from incompatible pointer type
include/linux/debugfs.h:68:16: note: expected ?size_t *? but argument is of type ?long unsigned int *?

On 09/13/2011 12:41 PM, Dan Magenheimer wrote:
> +#ifdef CONFIG_DEBUG_FS
> +	struct dentry *root = debugfs_create_dir("cleancache", NULL);
> +	if (root == NULL)
> +		return -ENXIO;
> +	debugfs_create_size_t("succ_gets", S_IRUGO,
> +				root, &cleancache_succ_gets);
> +	debugfs_create_size_t("failed_gets", S_IRUGO,
> +				root, &cleancache_failed_gets);
> +	debugfs_create_size_t("puts", S_IRUGO,
> +				root, &cleancache_puts);
> +	debugfs_create_size_t("invalidates", S_IRUGO,
> +				root, &cleancache_invalidates);
> +#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
