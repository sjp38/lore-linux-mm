Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 9DE466B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 09:23:31 -0400 (EDT)
Date: Fri, 29 Jun 2012 15:23:30 +0200
From: Petr Holasek <pholasek@redhat.com>
Subject: Re: [PATCH v2] KSM: numa awareness sysfs knob
Message-ID: <20120629132330.GA20670@dhcp-27-244.brq.redhat.com>
References: <1340970592-25001-1-git-send-email-pholasek@redhat.com>
 <jsk93p$32e$1@dough.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <jsk93p$32e$1@dough.gmane.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 29 Jun 2012, Cong Wang wrote:
> On Fri, 29 Jun 2012 at 11:49 GMT, Petr Holasek <pholasek@redhat.com> wrote:
> > -		root_unstable_tree = RB_ROOT;
> > +		for (i = 0; i < MAX_NUMNODES; i++)
> > +			root_unstable_tree[i] = RB_ROOT;
> 
> 
> This is not aware of memory-hotplug, right?
> 

What makes you think so?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
