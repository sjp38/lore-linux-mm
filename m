Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 835196B0005
	for <linux-mm@kvack.org>; Thu,  7 Feb 2013 07:59:14 -0500 (EST)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Thu, 7 Feb 2013 12:57:29 -0000
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r17Cx0iE34865332
	for <linux-mm@kvack.org>; Thu, 7 Feb 2013 12:59:00 GMT
Received: from d06av10.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r17BnQqN029404
	for <linux-mm@kvack.org>; Thu, 7 Feb 2013 06:49:26 -0500
Date: Thu, 7 Feb 2013 13:59:04 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH] mm: don't overwrite mm->def_flags in do_mlockall()
Message-ID: <20130207135904.0ca7a3d5@thinkpad>
In-Reply-To: <20130206125103.61748ed0.akpm@linux-foundation.org>
References: <1360165774-55458-1-git-send-email-gerald.schaefer@de.ibm.com>
	<20130206125103.61748ed0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vivek Goyal <vgoyal@redhat.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michel Lespinasse <walken@google.com>

On Wed, 6 Feb 2013 12:51:03 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed,  6 Feb 2013 16:49:34 +0100
> Gerald Schaefer <gerald.schaefer@de.ibm.com> wrote:
> 
> > With commit 8e72033 "thp: make MADV_HUGEPAGE check for
> > mm->def_flags" the VM_NOHUGEPAGE flag may be set on s390 in
> > mm->def_flags for certain processes, to prevent future thp
> > mappings. This would be overwritten by do_mlockall(), which sets it
> > back to 0 with an optional VM_LOCKED flag set.
> > 
> > To fix this, instead of overwriting mm->def_flags in do_mlockall(),
> > only the VM_LOCKED flag should be set or cleared.
> 
> What are the user-visible effects here?  Looking at the 274023da1e8
> changelog, I'm guessing that it might be pretty nasty - kvm breakage?

Yes, though at the moment there should be no mlockall()/munlockall()
involved with kvm/qemu. So currently no user-visible effects, Vivek
found this while reading the do_mlockall() code, but it might be a
good idea to add this to stable.
Could you add a "Cc: stable@vger.kernel.org # v3.7+"?

Thanks,
Gerald

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
