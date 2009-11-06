Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6F7C56B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 23:11:30 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA64BRBT019361
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 6 Nov 2009 13:11:27 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9176645DE79
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 13:11:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FF9045DE6F
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 13:11:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 13F2F1DB8037
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 13:11:27 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A07241DB8040
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 13:11:26 +0900 (JST)
Date: Fri, 6 Nov 2009 13:08:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [MM] Make mm counters per cpu instead of atomic V2
Message-Id: <20091106130853.f9e29574.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.1.10.0911051035100.25718@V090114053VZO-1>
References: <alpine.DEB.1.10.0911041409020.7409@V090114053VZO-1>
	<20091104234923.GA25306@redhat.com>
	<alpine.DEB.1.10.0911051004360.25718@V090114053VZO-1>
	<alpine.DEB.1.10.0911051035100.25718@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Dave Jones <davej@redhat.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Nov 2009 10:36:06 -0500 (EST)
Christoph Lameter <cl@linux-foundation.org> wrote:
> +static inline unsigned long get_mm_rss(struct mm_struct *mm)
> +{
> +	int cpu;
> +	unsigned long r = 0;
> +
> +	for_each_possible_cpu(cpu) {
> +		struct mm_counter *c = per_cpu_ptr(mm->rss, cpu);
> +
> +		r = c->file + c->anon;

r += c->file + c->anon;

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
