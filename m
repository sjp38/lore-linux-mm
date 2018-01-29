Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id CCD4E6B0003
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 13:24:02 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id a63so6335747wrc.15
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 10:24:02 -0800 (PST)
Received: from a3.inai.de (a3.inai.de. [2a01:4f8:162:73ab::58c6:b4a1])
        by mx.google.com with ESMTPS id 132si7999316wmg.109.2018.01.29.10.24.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jan 2018 10:24:01 -0800 (PST)
Date: Mon, 29 Jan 2018 19:24:01 +0100 (CET)
From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [netfilter-core] kernel panic: Out of memory and no killable
 processes... (2)
In-Reply-To: <20180129165722.GF5906@breakpoint.cc>
Message-ID: <alpine.LSU.2.20.1801291917130.15985@n3.vanv.qr>
References: <001a1144b0caee2e8c0563d9de0a@google.com> <201801290020.w0T0KK8V015938@www262.sakura.ne.jp> <20180129072357.GD5906@breakpoint.cc> <20180129082649.sysf57wlp7i7ltb2@node.shutemov.name> <20180129165722.GF5906@breakpoint.cc>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Westphal <fw@strlen.de>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, davem@davemloft.net, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, aarcange@redhat.com, yang.s@alibaba-inc.com, mhocko@suse.com, syzkaller-bugs@googlegroups.com, linux-kernel@vger.kernel.org, mingo@kernel.org, linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, guro@fb.com, kirill.shutemov@linux.intel.com


On Monday 2018-01-29 17:57, Florian Westphal wrote:
>> > > vmalloc() once became killable by commit 5d17a73a2ebeb8d1 ("vmalloc: back
>> > > off when the current task is killed") but then became unkillable by commit
>> > > b8c8a338f75e052d ("Revert "vmalloc: back off when the current task is
>> > > killed""). Therefore, we can't handle this problem from MM side.
>> > > Please consider adding some limit from networking side.
>> > 
>> > I don't know what "some limit" would be.  I would prefer if there was
>> > a way to supress OOM Killer in first place so we can just -ENOMEM user.
>> 
>> Just supressing OOM kill is a bad idea. We still leave a way to allocate
>> arbitrary large buffer in kernel.

At the very least, mm could limit that kind of "arbitrary". If the machine has
x GB (swap included) and the admin tries to make the kernel allocate space for
an x GB ruleset, no way is it going to be satisfiable _even with OOM_.

>I think we should try to allocate whatever amount of memory is needed
>for the given xtables ruleset, given that is what admin requested us to do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
