Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E2B406B0087
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 00:58:25 -0500 (EST)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp04.in.ibm.com (8.14.4/8.13.1) with ESMTP id oB75wKrU026779
	for <linux-mm@kvack.org>; Tue, 7 Dec 2010 11:28:20 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB75wKas2768918
	for <linux-mm@kvack.org>; Tue, 7 Dec 2010 11:28:20 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB75wJtx008476
	for <linux-mm@kvack.org>; Tue, 7 Dec 2010 16:58:20 +1100
Date: Mon, 6 Dec 2010 20:02:56 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [thisops uV3 08/18] Taskstats: Use this_cpu_ops
Message-ID: <20101206143256.GE3158@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20101130190707.457099608@linux.com>
 <20101130190845.819605614@linux.com>
 <1291226786.2898.22.camel@holzheu-laptop>
 <alpine.DEB.2.00.1012011212490.3774@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1012011212490.3774@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>, akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Christoph Lameter <cl@linux.com> [2010-12-01 12:13:44]:

> On Wed, 1 Dec 2010, Michael Holzheu wrote:
> 
> > >  		return -ENOMEM;
> > >
> > >  	if (!info) {
> > > -		int seq = get_cpu_var(taskstats_seqnum)++;
> > > -		put_cpu_var(taskstats_seqnum);
> > > +		int seq = this_cpu_inc_return(taskstats_seqnum);
> >
> > Hmmm, wouldn't seq now always be one more than before?
> >
> > I think that "seq = get_cpu_var(taskstats_seqnum)++" first assigns
> > taskstats_seqnum to seq and then increases the value in contrast to
> > this_cpu_inc_return() that returns the already increased value, correct?
> 
> Correct. We need to subtract one from that (which will eliminate the minus
> -1 that the inline this_cpu_inc_return creates).
>

But that breaks current behaviour, we should probably initialize all
of the array to -1? 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
