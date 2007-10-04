Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id l94GA5iq018353
	for <linux-mm@kvack.org>; Thu, 4 Oct 2007 09:10:05 -0700
Received: from nz-out-0506.google.com (nzfk1.prod.google.com [10.36.187.1])
	by zps36.corp.google.com with ESMTP id l94G9adH029796
	for <linux-mm@kvack.org>; Thu, 4 Oct 2007 09:10:03 -0700
Received: by nz-out-0506.google.com with SMTP id k1so191274nzf
        for <linux-mm@kvack.org>; Thu, 04 Oct 2007 09:10:03 -0700 (PDT)
Message-ID: <6599ad830710040910u3696df8p3c0448555cac23e@mail.gmail.com>
Date: Thu, 4 Oct 2007 09:10:02 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: Memory controller merge (was Re: -mm merge plans for 2.6.24)
In-Reply-To: <Pine.LNX.4.64.0710021604260.4916@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071001142222.fcaa8d57.akpm@linux-foundation.org>
	 <4701C737.8070906@linux.vnet.ibm.com>
	 <Pine.LNX.4.64.0710021604260.4916@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 10/2/07, Hugh Dickins <hugh@veritas.com> wrote:
>
> I accept that full swap control is something you're intending to add
> incrementally later; but the current state doesn't make sense to me.

One comment on swap - ideally it should be a separate subsystem from
the memory controller. That way people who are using cpusets to
provide memory isolation (rather than using the page-based memory
controller) can also get swap isolation.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
