Subject: Re: [PATCH 1/2] cgroup map files: Add cgroup map data type
In-Reply-To: Your message of "Thu, 21 Feb 2008 13:28:55 -0800"
	<20080221213444.898896000@menage.corp.google.com>
References: <20080221213444.898896000@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080222035158.89C4F1E3C58@siro.lan>
Date: Fri, 22 Feb 2008 12:51:58 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: menage@google.com
Cc: kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, balbir@in.ibm.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

> The map type is printed in a similar format to /proc/meminfo or
> /proc/<pid>/status, i.e. "$key: $value\n"

this description doesn't seem to match with the code.

YAMAMOTO Takashi

> +static int cgroup_map_add(struct cgroup_map_cb *cb, const char *key, u64 value)
> +{
> +	struct seq_file *sf = cb->state;
> +	return seq_printf(sf, "%s %llu\n", key, value);
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
