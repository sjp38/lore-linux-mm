Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 1BB64900136
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 16:41:09 -0400 (EDT)
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 13 Sep 2011 14:41:06 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8DKeiD8165754
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 14:40:45 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8DKeW0Y000310
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 14:40:33 -0600
Message-ID: <4E6FBFC4.1080901@linux.vnet.ibm.com>
Date: Tue, 13 Sep 2011 15:40:36 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH V9 3/6] mm: frontswap: core frontswap functionality
References: <20110913174026.GA11298@ca-server1.us.oracle.com>
In-Reply-To: <20110913174026.GA11298@ca-server1.us.oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, konrad.wilk@oracle.com, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, chris.mason@oracle.com, kamezawa.hiroyu@jp.fujitsu.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

Hey Dan,

I get the following compile warnings:

mm/frontswap.c: In function ?init_frontswap?:
mm/frontswap.c:264:5: warning: passing argument 4 of ?debugfs_create_size_t? from incompatible pointer type
include/linux/debugfs.h:68:16: note: expected ?size_t *? but argument is of type ?long unsigned int *?
mm/frontswap.c:266:5: warning: passing argument 4 of ?debugfs_create_size_t? from incompatible pointer type
include/linux/debugfs.h:68:16: note: expected ?size_t *? but argument is of type ?long unsigned int *?
mm/frontswap.c:268:5: warning: passing argument 4 of ?debugfs_create_size_t? from incompatible pointer type
include/linux/debugfs.h:68:16: note: expected ?size_t *? but argument is of type ?long unsigned int *?
mm/frontswap.c:270:5: warning: passing argument 4 of ?debugfs_create_size_t? from incompatible pointer type
include/linux/debugfs.h:68:16: note: expected ?size_t *? but argument is of type ?long unsigned int *?

size_t is platform dependent but is generally "unsigned int"
for 32-bit and "unsigned long" for 64-bit.

I think just typecasting these to size_t * would fix it.

On 09/13/2011 12:40 PM, Dan Magenheimer wrote:
> +#ifdef CONFIG_DEBUG_FS
> +	struct dentry *root = debugfs_create_dir("frontswap", NULL);
> +	if (root == NULL)
> +		return -ENXIO;
> +	debugfs_create_size_t("gets", S_IRUGO,
> +				root, &frontswap_gets);
> +	debugfs_create_size_t("succ_puts", S_IRUGO,
> +				root, &frontswap_succ_puts);
> +	debugfs_create_size_t("puts", S_IRUGO,
> +				root, &frontswap_failed_puts);
> +	debugfs_create_size_t("invalidates", S_IRUGO,
> +				root, &frontswap_invalidates);
> +#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
