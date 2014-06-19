Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id EAB706B0037
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 16:32:03 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kq14so2270798pab.20
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 13:32:03 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id iw9si6971073pbd.234.2014.06.19.13.32.02
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 13:32:03 -0700 (PDT)
Date: Thu, 19 Jun 2014 13:32:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RESEND] slub: return correct error on slab_sysfs_init
Message-Id: <20140619133201.7f84ae4acbc1b9d8f65e2b4f@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.11.1406190939030.2785@gentwo.org>
References: <53A0EB84.7030308@oracle.com>
	<alpine.DEB.2.02.1406181314290.10339@chino.kir.corp.google.com>
	<alpine.DEB.2.11.1406190939030.2785@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: David Rientjes <rientjes@google.com>, Jeff Liu <jeff.liu@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, akpm@linuxfoundation.org

On Thu, 19 Jun 2014 09:39:54 -0500 (CDT) Christoph Lameter <cl@gentwo.org> wrote:

> On Wed, 18 Jun 2014, David Rientjes wrote:
> 
> > Why?  kset_create_and_add() can fail for a few other reasons other than
> > memory constraints and given that this is only done at bootstrap, it
> > actually seems like a duplicate name would be a bigger concern than low on
> > memory if another init call actually registered it.
> 
> Greg said that the only reason for failure would be out of memory.

The kset_create_and_add interface is busted - it should return an
ERR_PTR on error, not NULL.  This seems to be a common gregkh failing :(

It's plausible that out-of-memory is the most common reason for
kset_create_and_add() failure, dunno.

Jeff, the changelog wasn't a good one - it failed to describe the
reasons for the change.  What was wrong with ENOSYS and why is ENOMEM
more appropriate?  If Greg told us that out-of-memory is the only
possible reason for the failure then it would be useful to capture the
reasoning behind this within this changelog.

Also let's describe the effects of this patch.  It looks like it's just
cosmetic - if kset_create_and_add() fails, the kernel behavior will be
the same either way.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
