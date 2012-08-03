Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id B69DA6B0044
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 17:48:11 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2231677pbb.14
        for <linux-mm@kvack.org>; Fri, 03 Aug 2012 14:48:11 -0700 (PDT)
Date: Fri, 3 Aug 2012 14:48:06 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 1/7] hashtable: introduce a small and naive hashtable
Message-ID: <20120803214806.GM15477@google.com>
References: <1344003788-1417-1-git-send-email-levinsasha928@gmail.com>
 <1344003788-1417-2-git-send-email-levinsasha928@gmail.com>
 <20120803171515.GH15477@google.com>
 <501C407D.9080900@gmail.com>
 <20120803213017.GK15477@google.com>
 <501C458E.7050000@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <501C458E.7050000@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org

Hello,

On Fri, Aug 03, 2012 at 11:41:34PM +0200, Sasha Levin wrote:
> I forgot to comment on that one, sorry.
> 
> If we put hash entries after struct hash_table we don't take the
> bits field size into account, or did I miss something?

So, if you do the following,

	struct {
		struct {
			int i;
			long ar[];
		} B;
		long __ar_storage[32];
	} A;

It should always be safe to dereference A.B.ar[31].  I'm not sure
whether this is something guaranteed by C tho.  Maybe compilers are
allowed to put members in reverse order but I think we already depend
on the above.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
