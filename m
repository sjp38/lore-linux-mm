In-reply-to: <20070417071703.959920360@chello.nl> (message from Peter Zijlstra
	on Tue, 17 Apr 2007 09:10:57 +0200)
Subject: Re: [PATCH 11/12] mm: per device dirty threshold
References: <20070417071046.318415445@chello.nl> <20070417071703.959920360@chello.nl>
Message-Id: <E1Heakt-0006jg-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 19 Apr 2007 19:49:15 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

> +static inline unsigned long bdi_stat_delta(void)
> +{
> +#ifdef CONFIG_SMP
> +	return NR_CPUS * FBC_BATCH;

Shouln't this be multiplied by the number of counters to sum?  I.e. 3
if dirty and unstable are separate, and 2 if they are not.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
