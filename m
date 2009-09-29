Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id AB24A6B005A
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 14:48:08 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e2.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n8TIicrO002275
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 14:44:38 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8TIpRkx1839170
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 14:51:27 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8TIpQm9024235
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 12:51:26 -0600
Date: Tue, 29 Sep 2009 13:51:26 -0500
From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH v18 49/80] c/r: support for UTS namespace
Message-ID: <20090929185126.GB13297@us.ibm.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com> <1253749920-18673-50-git-send-email-orenl@librato.com> <200909292213.21266@blacky.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200909292213.21266@blacky.localdomain>
Sender: owner-linux-mm@kvack.org
To: "Nikita V. Youshchenko" <yoush@cs.msu.su>
Cc: Oren Laadan <orenl@librato.com>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Dan Smith <danms@us.ibm.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Quoting Nikita V. Youshchenko (yoush@cs.msu.su):
> > +static struct uts_namespace *do_restore_uts_ns(struct ckpt_ctx *ctx)
> > ...
> > +#ifdef CONFIG_UTS_NS
> > +	uts_ns = create_uts_ns();
> > +	if (!uts_ns) {
> > +		uts_ns = ERR_PTR(-ENOMEM);
> > +		goto out;
> > +	}
> > +	down_read(&uts_sem);
> > +	name = &uts_ns->name;
> > +	memcpy(name->sysname, h->sysname, sizeof(name->sysname));
> > +	memcpy(name->nodename, h->nodename, sizeof(name->nodename));
> > +	memcpy(name->release, h->release, sizeof(name->release));
> > +	memcpy(name->version, h->version, sizeof(name->version));
> > +	memcpy(name->machine, h->machine, sizeof(name->machine));
> > +	memcpy(name->domainname, h->domainname, sizeof(name->domainname));
> > +	up_read(&uts_sem);
> 
> Could you please explain what for is this down_read() / up_read() ?
> You operate only on local objects: 'name' points to just-created 
> uts_ns, 'h' is also local data.

Yup, good point, that looks unnecessary.

thanks,
-serge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
