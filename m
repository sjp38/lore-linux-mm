Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 3F77F6B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 20:12:53 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so7346699pbb.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 17:12:52 -0700 (PDT)
Date: Tue, 16 Oct 2012 17:12:50 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: mpol_to_str revisited.
In-Reply-To: <CAHGf_=pemT6rcbu=dBVSJE7GuGWwVFP+Wn-mwkcsZ_gBGfaOsg@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1210161657220.14014@chino.kir.corp.google.com>
References: <20121008150949.GA15130@redhat.com> <CAHGf_=pr1AYeWZhaC2MKN-XjiWB7=hs92V0sH-zVw3i00X-e=A@mail.gmail.com> <alpine.DEB.2.00.1210152055150.5400@chino.kir.corp.google.com> <CAHGf_=rLjQbtWQLDcbsaq5=zcZgjdveaOVdGtBgBwZFt78py4Q@mail.gmail.com>
 <alpine.DEB.2.00.1210152306320.9480@chino.kir.corp.google.com> <CAHGf_=pemT6rcbu=dBVSJE7GuGWwVFP+Wn-mwkcsZ_gBGfaOsg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, bhutchings@solarflare.com, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 16 Oct 2012, KOSAKI Motohiro wrote:

> >> Even though 80de7c3138ee9fd86a98696fd2cf7ad89b995d0a itself is simple. It bring
> >> to caller complex. That's not good and have no worth.
> >>
> >
> > Before: the kernel panics, all workloads cease.
> > After: the file shows garbage, all workloads continue.
> >
> > This is better, in my opinion, but at best it's only a judgment call and
> > has no effect on anything.
> 
> Kernel panics help to find our serious mistake.
> 

Kernel panics are not your little debugging tool to let users suffer 
through for non-fatal issues.

> > I agree it would be better to respect the return value of mpol_to_str()
> > since there are other possible error conditions other than a freed
> > mempolicy, but let's not consider reverting 80de7c3138.  It is obviously
> > not a full solution to the problem, though, and we need to serialize with
> > task_lock().
> 
> Sorry no. I will have to revert it.

Feel free to revert anything you wish in your own tree, I couldn't care 
less.  If you try to propose it upstream, Andrew will surely ask you to 
justify the BUG(), good luck on that.

I'll reply to this message with the fix that I think is best.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
