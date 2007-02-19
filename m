Date: Mon, 19 Feb 2007 18:48:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH][3/4] Add reclaim support
Message-Id: <20070219184839.db9f3bc1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070219065042.3626.95544.sendpatchset@balbir-laptop>
References: <20070219065019.3626.33947.sendpatchset@balbir-laptop>
	<20070219065042.3626.95544.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@in.ibm.com>
Cc: linux-kernel@vger.kernel.org, vatsa@in.ibm.com, ckrm-tech@lists.sourceforge.net, xemul@sw.ru, linux-mm@kvack.org, menage@google.com, svaidy@linux.vnet.ibm.com, devel@openvz.org
List-ID: <linux-mm.kvack.org>

On Mon, 19 Feb 2007 12:20:42 +0530
Balbir Singh <balbir@in.ibm.com> wrote:

> +int memctlr_mm_overlimit(struct mm_struct *mm, void *sc_cont)
> +{
> +	struct container *cont;
> +	struct memctlr *mem;
> +	long usage, limit;
> +	int ret = 1;
> +
> +	if (!sc_cont)
> +		goto out;
> +
> +	read_lock(&mm->container_lock);
> +	cont = mm->container;

> +out:
> +	read_unlock(&mm->container_lock);
> +	return ret;
> +}
> +

should be
==
out_and_unlock:
	read_unlock(&mm->container_lock);
out_:
	return ret;


-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
