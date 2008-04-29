Received: by rn-out-0910.google.com with SMTP id j40so45004rnf.4
        for <linux-mm@kvack.org>; Tue, 29 Apr 2008 07:52:59 -0700 (PDT)
Message-ID: <661de9470804290752w1dc0cfb3k72e81d828a45765e@mail.gmail.com>
Date: Tue, 29 Apr 2008 20:22:58 +0530
From: "Balbir Singh" <balbir@linux.vnet.ibm.com>
Subject: Re: Page Faults slower in 2.6.25-rc9 than 2.6.23
In-Reply-To: <Pine.LNX.4.64.0804291447040.5058@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <d43160c70804290610t2135a271hd9b907529e89e74e@mail.gmail.com>
	 <Pine.LNX.4.64.0804291447040.5058@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Ross Biro <rossb@google.com>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 29, 2008 at 7:27 PM, Hugh Dickins <hugh@veritas.com> wrote:
> On Tue, 29 Apr 2008, Ross Biro wrote:
>  > I don't know if this has been noticed before.  I was benchmarking my
>  > page table relocation code and I noticed that on 2.6.25-rc9 page
>  > faults take 10% more time than on 2.6.22.  This is using lmbench
>  > running on an intel x86_64 system.  The good news is that the page
>  > table relocation code now only adds a 1.6% slow down to page faults.
>
>  Do you have CONFIG_CGROUP_MEM_RES_CTLR=y in 2.6.25?
>  That added about 20% to my lmbench "Page Fault" tests (with
>  adverse effect on several others e.g. the fork, exec, sh group).
>

Hmm.. strange.. I don't remember the overhead being so bad (I'll
relook at my old numbers). I'll try and git-bisect this one


>  Try the same kernel with boot option "cgroup_disable=memory",
>  that should recoup most (but not quite all) of the slowdown;
>  or rebuild with n to CGROUP_MEM_RES_CTLR.
>
>  But your "Mmap Latency" went up 425% ??
>

That's really way of the mark

>  Hugh
>

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
