Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id D6D4A6B005A
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 20:40:32 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id bi1so11149480pad.36
        for <linux-mm@kvack.org>; Mon, 07 Jan 2013 17:40:32 -0800 (PST)
Message-ID: <1357609227.4105.3.camel@kernel.cn.ibm.com>
Subject: Re: [PATCH v7 1/2] KSM: numa awareness sysfs knob
From: Simon Jeons <simon.jeons@gmail.com>
Date: Mon, 07 Jan 2013 19:40:27 -0600
In-Reply-To: <20130103122416.GB2277@thinkpad-work.redhat.com>
References: <20121224050817.GA25749@kroah.com>
	 <1356658337-12540-1-git-send-email-pholasek@redhat.com>
	 <1357015310.1379.2.camel@kernel.cn.ibm.com>
	 <20130103122416.GB2277@thinkpad-work.redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>

On Thu, 2013-01-03 at 13:24 +0100, Petr Holasek wrote:
> Hi Simon,
> 
> On Mon, 31 Dec 2012, Simon Jeons wrote:
> > On Fri, 2012-12-28 at 02:32 +0100, Petr Holasek wrote:
> > > 
> > > v7:	- added sysfs ABI documentation for KSM
> > 
> > Hi Petr,
> > 
> > How you handle "memory corruption because the ksm page still points to
> > the stable_node that has been freed" mentioned by Andrea this time?
> > 
> 

Hi Petr,

You still didn't answer my question mentioned above. :)

> <snip>
> 
> > >  
> > > +		/*
> > > +		 * If tree_page has been migrated to another NUMA node, it
> > > +		 * will be flushed out and put into the right unstable tree
> > > +		 * next time: only merge with it if merge_across_nodes.
> > 
> > Why? Do you mean swap based migration? Or where I miss ....?
> > 
> 
> It can be physical page migration triggered by page compaction, memory hotplug
> or some NUMA sched/memory balancing algorithm developed recently.
> 
> > > +		 * Just notice, we don't have similar problem for PageKsm
> > > +		 * because their migration is disabled now. (62b61f611e)
> > > +		 */
> 
> Migration of KSM pages is disabled now, you can look into ^^^ commit and
> changes introduced to migrate.c.
> 
> > > +		if (!ksm_merge_across_nodes && page_to_nid(tree_page) != nid) {
> > > +			put_page(tree_page);
> > > +			return NULL;
> > > +		}
> > > +
> > >  		ret = memcmp_pages(page, tree_page);
> 
> </snip>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
