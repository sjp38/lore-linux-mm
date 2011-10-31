Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7C35D6B0069
	for <linux-mm@kvack.org>; Mon, 31 Oct 2011 13:47:01 -0400 (EDT)
Date: Mon, 31 Oct 2011 18:42:38 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v2] oom: fix integer overflow of points in oom_badness
Message-ID: <20111031174238.GA7344@redhat.com>
References: <1320048865-13175-1-git-send-email-fhrbata@redhat.com> <1320076569-23872-1-git-send-email-fhrbata@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1320076569-23872-1-git-send-email-fhrbata@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frantisek Hrbata <fhrbata@redhat.com>
Cc: rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, stable@kernel.org, eteo@redhat.com, pmatouse@redhat.com

On 10/31, Frantisek Hrbata wrote:
>
>  unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
>  		      const nodemask_t *nodemask, unsigned long totalpages)
>  {
> -	int points;
> +	long points;

Good catch. Imho this is the stable material.

Acked-by: Oleg Nesterov <oleg@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
