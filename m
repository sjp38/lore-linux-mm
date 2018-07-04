Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id CB91B6B026E
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 10:36:55 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id r58-v6so3814007otr.0
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 07:36:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y57-v6si1079941oty.399.2018.07.04.07.36.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 07:36:54 -0700 (PDT)
Date: Wed, 4 Jul 2018 10:36:49 -0400
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH] mm: be more informative in OOM task list
Message-ID: <20180704143649.GE31826@xps>
References: <7de14c6cac4a486c04149f37948e3a76028f3fa5.1530461087.git.rfreire@redhat.com>
 <alpine.DEB.2.21.1807031832540.110853@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1807031832540.110853@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Rodrigo Freire <rfreire@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 03, 2018 at 06:34:48PM -0700, David Rientjes wrote:
> On Sun, 1 Jul 2018, Rodrigo Freire wrote:
> 
> > The default page memory unit of OOM task dump events might not be
> > intuitive for the non-initiated when debugging OOM events. Add
> > a small printk prior to the task dump informing that the memory
> > units are actually memory _pages_.
> > 
> > Signed-off-by: Rodrigo Freire <rfreire@redhat.com>
> > ---
> >  mm/oom_kill.c | 1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 84081e7..b4d9557 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -392,6 +392,7 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
> >  	struct task_struct *p;
> >  	struct task_struct *task;
> >  
> > +	pr_info("Tasks state (memory values in pages):\n");
> >  	pr_info("[ pid ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
> >  	rcu_read_lock();
> >  	for_each_process(p) {
> 
> As the author of dump_tasks(), and having seen these values misinterpreted 
> on more than one occassion, I think this is a valuable addition.
> 
> Could you also expand out the "pid" field to allow for seven digits 
> instead of five?  I think everything else is aligned.
> 
> Feel free to add
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
> to a v2.
>

Same here, for a v2:
 
Acked-by: Rafael Aquini <aquini@redhat.com>
