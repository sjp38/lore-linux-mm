Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 61B0B6B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 23:18:14 -0400 (EDT)
Received: by wa-out-1112.google.com with SMTP id m34so78699wag.22
        for <linux-mm@kvack.org>; Tue, 23 Jun 2009 20:18:46 -0700 (PDT)
Message-ID: <4A419A7F.8050604@gmail.com>
Date: Wed, 24 Jun 2009 11:16:15 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] remove unused line for mmap_region()
References: <1245595421-3441-1-git-send-email-shijie8@gmail.com> <Pine.LNX.4.64.0906211917350.4583@sister.anvils> <4A3EFF93.4000100@gmail.com> <Pine.LNX.4.64.0906231155180.6167@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0906231155180.6167@sister.anvils>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 
> I can't name a list of drivers offhand, no (but note VM_PFNMAP areas
> have a particular use for vm_pgoff, so all those drivers are likely
> to be on the list).  May I please leave that investigation to you?
>
>   
ok.
> What I expect you to find in the end is that every driver which does
> meddle with pgoff in its ->mmap, also has some other characteristic
> (e.g. sets VM_IO or VM_DONTEXPAND or VM_RESERVED or VM_PFNMAP, or
> even some other flag which the new vm_flags wouldn't have set),
> which will prevent its vmas being merged anyway.
>
>   
Unfortunately,the driver's -->mmap is called below the vma_merge(),
so even if the driver sets the VM_SPECIAL flag, it does not prevent the
vmas being merged actually.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
