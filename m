Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id ECE116B0096
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 17:18:56 -0500 (EST)
Date: Mon, 4 Feb 2013 14:18:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mmu_notifier_unregister NULL Pointer deref and multiple
 ->release() callouts. [V2]
Message-Id: <20130204141854.b13973d2.akpm@linux-foundation.org>
In-Reply-To: <20130204130306.GL3438@sgi.com>
References: <20130204130306.GL3438@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, linux-mm@kvack.org, Avi Kivity <avi@redhat.com>, Hugh Dickins <hughd@google.com>, Marcelo Tosatti <mtosatti@redhat.com>, Sagi Grimberg <sagig@mellanox.co.il>, Haggai Eran <haggaie@mellanox.com>, stable-kernel <stable@vger.kernel.org>

On Mon, 4 Feb 2013 07:03:06 -0600
Robin Holt <holt@sgi.com> wrote:

> 
> Cc: stable-kernel <stable@vger.kernel.org> # 3.[0-6].y 21a9273
> Cc: stable-kernel <stable@vger.kernel.org> # 3.[0-6].y 7040030
> Cc: stable-kernel <stable@vger.kernel.org>
> 
> ...
> 
> Andrew, I have a question about the stable maintainer bits I hope you
> could help me with.  Will the syntax I used above get this into 3.0.y
> through 3.7.y?  3.7.y does not need the other two commits, but all the
> rest do.  If not and you wouldn't mind fixing it up for me, I would
> appreciate the help.

um, I'd fix it up if I understood it, but I'm not sure that I do with
sufficient reliability.

If you want to send a message like this to Greg and to others who
maintain earlier kernel versions then I suggest you just spell it all
out in plain old English in the main changelog.  That's not very useful
information for people who are following mainline, but a couple
paragraphs in a changelog won't kill anyone.

So can you please send me those couple of paragraphs and I'll paste
them in there headlined "-stable suggestions".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
