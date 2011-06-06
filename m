Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id DBD156B004A
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 16:22:33 -0400 (EDT)
Received: by wwi36 with SMTP id 36so3528215wwi.26
        for <linux-mm@kvack.org>; Mon, 06 Jun 2011 13:22:30 -0700 (PDT)
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <4DEB8872.2060801@fnarfbargle.com>
References: <20110601011527.GN19505@random.random>
	 <alpine.LSU.2.00.1105312120530.22808@sister.anvils>
	 <4DE5DCA8.7070704@fnarfbargle.com> <4DE5E29E.7080009@redhat.com>
	 <4DE60669.9050606@fnarfbargle.com> <4DE60918.3010008@redhat.com>
	 <4DE60940.1070107@redhat.com> <4DE61A2B.7000008@fnarfbargle.com>
	 <20110601111841.GB3956@zip.com.au> <4DE62801.9080804@fnarfbargle.com>
	 <20110601230342.GC3956@zip.com.au> <4DE8E3ED.7080004@fnarfbargle.com>
	 <4DEB3AE4.8040700@redhat.com>  <4DEB8872.2060801@fnarfbargle.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 06 Jun 2011 22:22:26 +0200
Message-ID: <1307391746.2642.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brad Campbell <lists2009@fnarfbargle.com>
Cc: Avi Kivity <avi@redhat.com>, CaT <cat@zip.com.au>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm <linux-mm@kvack.org>, netdev <netdev@vger.kernel.org>

Le dimanche 05 juin 2011 A  21:45 +0800, Brad Campbell a A(C)crit :
> On 05/06/11 16:14, Avi Kivity wrote:
> > On 06/03/2011 04:38 PM, Brad Campbell wrote:
> >>
> >> Is there anyone who can point me at the appropriate cage to rattle? I
> >> know it appears to be a netfilter issue, but I don't seem to be able
> >> to get a message to the list (and I am subscribed to it and have been
> >> getting mail for months) and I'm not sure who to pester. The other
> >> alternative is I just stop doing "that" and wait for it to bite
> >> someone else.
> >
> > The mailing list might be set not to send your own mails back to you.
> > Check the list archive.
> 
> Yep, I did that first..
> 
> Given the response to previous issues along the same line, it looks a 
> bit like I just remember not to actually use the system in the way that 
> triggers the bug and be happy that 99% of the time the kernel does not 
> panic, but have that lovely feeling in the back of the skull that says 
> "any time now, and without obvious reason the whole machine might just 
> come crashing down"..
> 
> I guess it's still better than running Xen or Windows..

Could you please try latest linux-2.6 tree ?

We fixed many networking bugs that could explain your crash.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
