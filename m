Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 750406B007E
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 07:08:04 -0400 (EDT)
Message-ID: <1332760047.16159.93.camel@twins>
Subject: Re: [PATCH] cpuset: mm: Reduce large amounts of memory barrier
 related damage v3
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 26 Mar 2012 13:07:27 +0200
In-Reply-To: <1332759384.16159.92.camel@twins>
References: <20120307180852.GE17697@suse.de>
	 <1332759384.16159.92.camel@twins>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Miao Xie <miaox@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 2012-03-26 at 12:56 +0200, Peter Zijlstra wrote:
>  static inline bool put_mems_allowed(unsigned int seq)
>  {
> -       return !read_seqcount_retry(&current->mems_allowed_seq, seq);
> +       return likely(!read_seqcount_retry(&current->mems_allowed_seq, se=
q));
>  }=20

Ignore this hunk, read_seqcount_retry() already has a branch hint in.
I'll send a new version if people thing the rest of the patch is worth
it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
