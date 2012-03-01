Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 67EBF6B004A
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 17:33:47 -0500 (EST)
Date: Thu, 1 Mar 2012 14:33:45 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -V2 1/9] mm:  move hugetlbfs region tracking function to
 common code
Message-Id: <20120301143345.7e928efe.akpm@linux-foundation.org>
In-Reply-To: <1330593380-1361-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1330593380-1361-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<1330593380-1361-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Andrea Righi <andrea@betterlinux.com>, John Stultz <john.stultz@linaro.org>

On Thu,  1 Mar 2012 14:46:12 +0530
"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> This patch moves the hugetlbfs region tracking function to
> common code. We will be using this in later patches in the
> series.
> 
> ...
>
> +struct file_region {
> +	struct list_head link;
> +	long from;
> +	long to;
> +};

Both Andrea Righi and John Stultz are working on (more sophisticated)
versions of file region tracking code.  And we already have a (poor)
implementation in fs/locks.c.

That's four versions of the same thing floating around the place.  This
is nutty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
