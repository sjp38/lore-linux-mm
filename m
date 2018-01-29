Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id A9CEE6B0003
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 13:25:25 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id i12so844009wra.22
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 10:25:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z71si7999538wmz.2.2018.01.29.10.25.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Jan 2018 10:25:24 -0800 (PST)
Date: Mon, 29 Jan 2018 19:25:21 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [netfilter-core] kernel panic: Out of memory and no killable
 processes... (2)
Message-ID: <20180129182521.GI21609@dhcp22.suse.cz>
References: <001a1144b0caee2e8c0563d9de0a@google.com>
 <201801290020.w0T0KK8V015938@www262.sakura.ne.jp>
 <20180129072357.GD5906@breakpoint.cc>
 <20180129082649.sysf57wlp7i7ltb2@node.shutemov.name>
 <20180129165722.GF5906@breakpoint.cc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180129165722.GF5906@breakpoint.cc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Westphal <fw@strlen.de>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, davem@davemloft.net, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, aarcange@redhat.com, yang.s@alibaba-inc.com, syzkaller-bugs@googlegroups.com, linux-kernel@vger.kernel.org, mingo@kernel.org, linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, guro@fb.com, kirill.shutemov@linux.intel.com

On Mon 29-01-18 17:57:22, Florian Westphal wrote:
> Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > On Mon, Jan 29, 2018 at 08:23:57AM +0100, Florian Westphal wrote:
> > > > vmalloc() once became killable by commit 5d17a73a2ebeb8d1 ("vmalloc: back
> > > > off when the current task is killed") but then became unkillable by commit
> > > > b8c8a338f75e052d ("Revert "vmalloc: back off when the current task is
> > > > killed""). Therefore, we can't handle this problem from MM side.
> > > > Please consider adding some limit from networking side.
> > > 
> > > I don't know what "some limit" would be.  I would prefer if there was
> > > a way to supress OOM Killer in first place so we can just -ENOMEM user.
> > 
> > Just supressing OOM kill is a bad idea. We still leave a way to allocate
> > arbitrary large buffer in kernel.
> 
> Isn't that what we do everywhere in network stack?
> 
> I think we should try to allocate whatever amount of memory is needed
> for the given xtables ruleset, given that is what admin requested us to do.

If this is a root only thing then __GFP_NORETRY sounds like the most
straightforward way to go.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
