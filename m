Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8111B6B0023
	for <linux-mm@kvack.org>; Wed, 14 Sep 2011 15:15:03 -0400 (EDT)
Received: by bkbzs2 with SMTP id zs2so2386669bkb.14
        for <linux-mm@kvack.org>; Wed, 14 Sep 2011 12:14:58 -0700 (PDT)
Date: Wed, 14 Sep 2011 23:14:17 +0400
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [RFC PATCH 2/2] mm: restrict access to /proc/slabinfo
Message-ID: <20110914191417.GA15936@albatros>
References: <20110910164001.GA2342@albatros>
 <20110910164134.GA2442@albatros>
 <1316025701.4478.65.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1316025701.4478.65.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: kernel-hardening@lists.openwall.com, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Sep 14, 2011 at 11:41 -0700, Dave Hansen wrote:
> On Sat, 2011-09-10 at 20:41 +0400, Vasiliy Kulikov wrote:
> > @@ -4584,7 +4584,8 @@ static const struct file_operations proc_slabstats_operations = {
> >  
> >  static int __init slab_proc_init(void)
> >  {
> > -       proc_create("slabinfo",S_IWUSR|S_IRUGO,NULL,&proc_slabinfo_operations);
> > +       proc_create("slabinfo", S_IWUSR | S_IRUSR, NULL,
> > +                   &proc_slabinfo_operations);
> >  #ifdef CONFIG_DEBUG_SLAB_LEAK
> >         proc_create("slab_allocators", 0, NULL, &proc_sla 
> 
> If you respin this, please don't muck with the whitespace.

OK, I was just removing checkpatch warnings.

>  Otherwise,
> I'm fine with this.  Distros are already starting to do this anyway in
> userspace.
> 
> Reviewed-by: Dave Hansen <dave@linux.vnet.ibm.com>

Thank you!

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
