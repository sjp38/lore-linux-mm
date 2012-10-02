Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id A1C6A6B00C9
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 07:08:33 -0400 (EDT)
Message-ID: <1349176139.10698.15.camel@jlt4.sipsolutions.net>
Subject: Re: slab vs. slub kmem cache name inconsistency
From: Johannes Berg <johannes@sipsolutions.net>
Date: Tue, 02 Oct 2012 13:08:59 +0200
In-Reply-To: <CAAmzW4OvWVfHhqs3puzArvVoNp4ZopZXdc38RVmFBkMd_LjNWA@mail.gmail.com> (sfid-20121002_130550_956053_D126E2C4)
References: <1349170840.10698.14.camel@jlt4.sipsolutions.net>
	 <CAAmzW4OvWVfHhqs3puzArvVoNp4ZopZXdc38RVmFBkMd_LjNWA@mail.gmail.com>
	 (sfid-20121002_130550_956053_D126E2C4)
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

Hi,

> > I just noticed that slub's kmem_cache_create() will kstrdup() the name,
> > while slab doesn't. That's a little confusing, since when you look at
> > slub you can easily get away with passing a string you built on the
> > stack, while that will then lead to very strange results (and possibly
> > crashes?) with slab.
> 
> As far as I know, this issue is already fixed. However, fix for this
> is not merged into mainline yet.
> You can find the fix in common_for_cgroups branch of Pekka's git tree.
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/penberg/linux.git
> slab/common-for-cgroups

Cool, yes, we have a commit there which addresses this:

http://git.kernel.org/?p=linux/kernel/git/penberg/linux.git;a=commit;h=db265eca77000c5dafc5608975afe8dafb2a02d5

Thanks!

johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
