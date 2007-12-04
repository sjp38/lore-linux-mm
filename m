Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id lB4968VY032699
	for <linux-mm@kvack.org>; Tue, 4 Dec 2007 01:06:08 -0800
Received: from py-out-1112.google.com (pyia29.prod.google.com [10.34.253.29])
	by zps35.corp.google.com with ESMTP id lB495uJL017786
	for <linux-mm@kvack.org>; Tue, 4 Dec 2007 01:06:08 -0800
Received: by py-out-1112.google.com with SMTP id a29so10408626pyi
        for <linux-mm@kvack.org>; Tue, 04 Dec 2007 01:06:07 -0800 (PST)
Message-ID: <532480950712040106r144ed43m5cb77cc394e2ec8a@mail.gmail.com>
Date: Tue, 4 Dec 2007 01:06:06 -0800
From: "Michael Rubin" <mrubin@google.com>
Subject: Re: [patch 1/1] Writeback fix for concurrent large and small file writes
In-Reply-To: <396386387.18082@ustc.edu.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071128192957.511EAB8310@localhost> <396296481.07368@ustc.edu.cn>
	 <532480950711291216l181b0bej17db6c42067aa832@mail.gmail.com>
	 <396386387.18082@ustc.edu.cn>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Fengguang Wu <wfg@mail.ustc.edu.cn>
Cc: a.p.zijlstra@chello.nl, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

On Nov 29, 2007 5:32 PM, Fengguang Wu <wfg@mail.ustc.edu.cnwrote:
> > On Nov 28, 2007 4:34 PM, Fengguang Wu <wfg@mail.ustc.edu.cn> wrote:
> > > Could you demonstrate the situation? Or if I guess it right, could it
> > > be fixed by the following patch?

Feng I am sorry to have been mistaken but I reran my tests and I am
now finding that the patch you gave me is NOT fixing the problem.  The
patch I refer to is the one you posted on this thread that adds a
requeue_io in __sync_single_inode.

I tarred up my test code. It is still in very rough shape but it can
reproduce the issue. You can find it here:

http://neverthere.org/mhr/wb/wb-test.tar.bz2

Just make the test and run it with the args "-duration 0:5:0
-starvation". You must be root so it can set some sysctl values.

> One major concern could be whether a continuous writer dirting pages
> at the 'right' pace will generate a steady flow of write I/Os which are
> _tiny_hence_inefficient_.
>
> So it's not a problem in *theory* :-)
>
> > I will post this change for 2.6.24 and list Feng as author. If that's
> > ok with Feng.

I am going to try to track down what is up in 2.6.24 and see if I can
find a less dramatic fix than my tree patch for the short term. If you
get a chance to reproduce the problem with my test on your patch that
would rock.

I still would like to see my full patch accepted into 2.6.25. A patch
should be arriving shortly that will incorporate my larger patch and
Qi Yong's fix for skip-writing-data-pages-when-inode-is-under-i_sync.
http://www.gossamer-threads.com/lists/linux/kernel/849493

As always thanks for your patience,

mrubin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
