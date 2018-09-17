Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0C2E48E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 16:22:59 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id p5-v6so8898839pfh.11
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 13:22:59 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m86-v6si17191811pfj.48.2018.09.17.13.22.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Sep 2018 13:22:57 -0700 (PDT)
Date: Mon, 17 Sep 2018 22:22:38 +0200
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: Patch "x86/kexec: Allocate 8k PGDs for PTI" has been added to
 the 3.18-stable tree
Message-ID: <20180917202238.GA9048@kroah.com>
References: <1537177617126129@kroah.com>
 <alpine.LSU.2.11.1809171213560.1601@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1809171213560.1601@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: 1532533683-5988-4-git-send-email-joro@8bytes.org, David.Laight@aculab.com, aarcange@redhat.com, acme@kernel.org, alexander.levin@microsoft.com, alexander.shishkin@linux.intel.com, aliguori@amazon.com, boris.ostrovsky@oracle.com, bp@alien8.de, brgerst@gmail.com, daniel.gruss@iaik.tugraz.at, dave.hansen@intel.com, dhgutteridge@sympatico.ca, dvlasenk@redhat.com, eduval@amazon.com, hpa@zytor.com, jgross@suse.com, jkosina@suse.cz, jolsa@redhat.comjoro@8bytes.org, jpoimboe@redhat.com, jroedel@suse.de, keescook@google.com, linux-mm@kvack.org, llong@redhat.com, luto@kernel.org, namhyung@kernel.org, pavel@ucw.cz, peterz@infradead.org, tglx@linutronix.de, torvalds@linux-foundation.org, will.deacon@arm.com, stable-commits@vger.kernel.org, stable@vger.kernel.org

On Mon, Sep 17, 2018 at 12:33:47PM -0700, Hugh Dickins wrote:
> On Mon, 17 Sep 2018, gregkh@linuxfoundation.org wrote:
> > 
> > This is a note to let you know that I've just added the patch titled
> > 
> >     x86/kexec: Allocate 8k PGDs for PTI
> > 
> > to the 3.18-stable tree which can be found at:
> >     http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary
> > 
> > The filename of the patch is:
> >      x86-kexec-allocate-8k-pgds-for-pti.patch
> > and it can be found in the queue-3.18 subdirectory.
> > 
> > If you, or anyone else, feels it should not be added to the stable tree,
> > please let <stable@vger.kernel.org> know about it.
> 
> I believe this commit is an example of the auto-selector being too
> eager, and this should not be in *any* of the stable trees.  As the
> commit message indicates, it's a fix by Joerg for his PTI-x86-32
> implementation - which has not been backported to any of the stable
> trees (yet), has it?
> 
> In several of the recent stable trees, I think this will not do any
> actual harm; but it looks as if it will prevent relevant x86-32 configs
> from building on 3.18 (I see no definition of PGD_ALLOCATION_ORDER in
> linux-3.18.y - you preferred not to have any PTI in that tree), and I
> haven't checked whether its definition in older backports will build
> correctly here or not.

Ah, you are right, I just got a build failure report from the 4.4.y tree
with this exact error.

Thanks for letting me know, I'll go drop this from all of the stable
tree queues right now.

greg k-h
