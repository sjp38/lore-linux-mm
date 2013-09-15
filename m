Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 64BBA6B0082
	for <linux-mm@kvack.org>; Sun, 15 Sep 2013 14:56:27 -0400 (EDT)
Date: Sun, 15 Sep 2013 14:56:13 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2 v3] memcg: refactor mem_control_numa_stat_show()
Message-ID: <20130915185613.GB3278@cmpxchg.org>
References: <1378362539-18100-1-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1378362539-18100-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, hughd@google.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>

Hi Greg,

On Wed, Sep 04, 2013 at 11:28:58PM -0700, Greg Thelen wrote:
> +	struct numa_stat {
> +		const char *name;
> +		unsigned int lru_mask;
> +	};
> +
> +	static const struct numa_stat stats[] = {
> +		{ "total", LRU_ALL },
> +		{ "file", LRU_ALL_FILE },
> +		{ "anon", LRU_ALL_ANON },
> +		{ "unevictable", BIT(LRU_UNEVICTABLE) },
> +		{ NULL, 0 }  /* terminator */
> +	};

[...]

> +	for (stat = stats; stat->name; stat++) {

Please drop the NULL terminator and use ARRAY_SIZE().

Otherwise, looks good to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
