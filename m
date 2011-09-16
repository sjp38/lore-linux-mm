Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 51DC29000BD
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 11:13:01 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8GDpkl8014758
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 09:51:46 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8GFCN6s220406
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 11:12:23 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8GFCG1l030383
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 11:12:20 -0400
Message-ID: <4E73674B.6090901@linux.vnet.ibm.com>
Date: Fri, 16 Sep 2011 10:12:11 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH V10 3/6] mm: frontswap: core frontswap functionality
References: <20110915213406.GA26369@ca-server1.us.oracle.com>
In-Reply-To: <20110915213406.GA26369@ca-server1.us.oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, konrad.wilk@oracle.com, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, chris.mason@oracle.com, kamezawa.hiroyu@jp.fujitsu.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

On 09/15/2011 04:34 PM, Dan Magenheimer wrote:
> From: Dan Magenheimer <dan.magenheimer@oracle.com>
> Subject: [PATCH V10 3/6] mm: frontswap: core frontswap functionality
> 
> (Note to earlier reviewers:  This patchset has been reorganized due to
> feedback from Kame Hiroyuki and Andrew Morton. This patch contains part
> of patch 3of4 from the previous series.)
> 
> This third patch of six in the frontswap series provides the core
> frontswap code that interfaces between the hooks in the swap subsystem
> and a frontswap backend via frontswap_ops.
> 
> [v10: sjenning@linux.vnet.ibm.com: fix debugfs calls on 32-bit]
...
> +#ifdef CONFIG_DEBUG_FS
> +	struct dentry *root = debugfs_create_dir("frontswap", NULL);
> +	if (root == NULL)
> +		return -ENXIO;
> +	debugfs_create_u64("gets", S_IRUGO, root, &frontswap_gets);
> +	debugfs_create_u64("succ_puts", S_IRUGO, root, &frontswap_succ_puts);
> +	debugfs_create_u64("puts", S_IRUGO, root, &frontswap_failed_puts);

Sorry I didn't see this one before :-/  This should be "failed_puts",
not "puts".

Other than that, it compiles cleanly here and runs without issue when
applied on 3.1-rc4 + fix for cleancache crash.

Thanks
--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
