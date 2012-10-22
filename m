Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 3E7F36B007B
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 13:24:13 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jm1so1122160bkc.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 10:24:11 -0700 (PDT)
Subject: Re: PROBLEM: Memory leak (at least with SLUB) from "secpath_dup"
 (xfrm) in 3.5+ kernels
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <20121022225918.32d86a5f@sacrilege>
References: <20121019205055.2b258d09@sacrilege>
	 <20121019233632.26cf96d8@sacrilege>
	 <CAHC9VhQ+gkAaRmwDWqzQd1U-hwH__5yxrxWa5_=koz_XTSXpjQ@mail.gmail.com>
	 <20121020204958.4bc8e293@sacrilege> <20121021044540.12e8f4b7@sacrilege>
	 <20121021062402.7c4c4cb8@sacrilege>
	 <1350826183.13333.2243.camel@edumazet-glaptop>
	 <20121021195701.7a5872e7@sacrilege> <20121022004332.7e3f3f29@sacrilege>
	 <20121022015134.4de457b9@sacrilege>
	 <1350856053.8609.217.camel@edumazet-glaptop>
	 <20121022045850.788df346@sacrilege>
	 <1350893743.8609.424.camel@edumazet-glaptop>
	 <20121022180655.50a50401@sacrilege>
	 <1350918997.8609.858.camel@edumazet-glaptop>
	 <1350919337.8609.869.camel@edumazet-glaptop>
	 <1350919682.8609.877.camel@edumazet-glaptop>
	 <20121022225918.32d86a5f@sacrilege>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 22 Oct 2012 19:24:07 +0200
Message-ID: <1350926647.8609.1006.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kazantsev <mk.fraggod@gmail.com>
Cc: Paul Moore <paul@paul-moore.com>, netdev@vger.kernel.org, linux-mm@kvack.org

On Mon, 2012-10-22 at 22:59 +0600, Mike Kazantsev wrote:
> On Mon, 22 Oct 2012 17:28:02 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > On Mon, 2012-10-22 at 17:22 +0200, Eric Dumazet wrote:
> > > On Mon, 2012-10-22 at 17:16 +0200, Eric Dumazet wrote:
> > > 
> > > > OK, I believe I found the bug in IPv4 defrag / IPv6 reasm
> > > > 
> > > > Please test the following patch.
> > > > 
> > > > Thanks !
> > > 
> > > I'll send a more generic patch in a few minutes, changing
> > > kfree_skb_partial() to call skb_release_head_state()
> > > 
> > 
> > Here it is :
> > 
> ...
> 
> Problem is indeed gone in v3.7-rc2 with the proposed generic patch, I
> haven't read the mail in time to test the first one, but I guess it's
> not relevant now that the latter one works.
> 
> Thank you for taking your time to look into the problem and actually
> fix it.
> 
> I'm unclear about policies in place on the matter, but I think this
> patch might be a good candidate to backport into 3.5 and 3.6 kernels,
> because they seem to suffer from the issue as well.

Thanks a lot Mike for your help.

Dont worry, I'll submit an official patch with details and all credits. 

David Miller will forward it to stable teams.

Thanks !



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
