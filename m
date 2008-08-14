Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id m7E8cJhC019726
	for <linux-mm@kvack.org>; Thu, 14 Aug 2008 09:38:19 +0100
Received: from rv-out-0708.google.com (rvbf25.prod.google.com [10.140.82.25])
	by wpaz21.hot.corp.google.com with ESMTP id m7E8cIUB029873
	for <linux-mm@kvack.org>; Thu, 14 Aug 2008 01:38:18 -0700
Received: by rv-out-0708.google.com with SMTP id f25so320946rvb.14
        for <linux-mm@kvack.org>; Thu, 14 Aug 2008 01:38:17 -0700 (PDT)
Message-ID: <6599ad830808140138u15f516fdpace0ba455406efd4@mail.gmail.com>
Date: Thu, 14 Aug 2008 01:38:17 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH][RFC] dirty balancing for cgroups
In-Reply-To: <1216043344.12595.89.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080711141511.515e69a5.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080711055926.9AF4F5A03@siro.lan>
	 <20080711161349.c5831081.kamezawa.hiroyu@jp.fujitsu.com>
	 <1216043344.12595.89.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 14, 2008 at 6:49 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>
> The dirty page limit avoids deadlocks under certain situations, the per
> BDI dirty limit avoids even mode deadlocks by providing isolation
> between BDIs.
>

As well as deadlocks, in the case of cgroups a big advantage of dirty
limits is that it makes it easier to "loan" memory to groups above and
beyond what they have been guaranteed. As long as we limit the
dirty/locked memory for a cgroup to its guarantee, and require any
extra memory to be clean and unlocked, then we can reclaim it in a
hurry if another cgroup (that had been guaranteed that memory) needs
it.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
