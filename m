Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id BA2846B0044
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 19:48:09 -0400 (EDT)
Received: by wgbdq12 with SMTP id dq12so1015027wgb.26
        for <linux-mm@kvack.org>; Fri, 03 Aug 2012 16:48:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120803223634.GO15477@google.com>
References: <1344003788-1417-1-git-send-email-levinsasha928@gmail.com>
 <1344003788-1417-2-git-send-email-levinsasha928@gmail.com>
 <20120803171515.GH15477@google.com> <501C407D.9080900@gmail.com>
 <20120803213017.GK15477@google.com> <501C458E.7050000@gmail.com>
 <20120803214806.GM15477@google.com> <501C4E92.1070801@gmail.com>
 <20120803222339.GN15477@google.com> <CA+55aFyOst4c3WHbPVbYkSBdBmLJUui5OvoVOh5AuPMnigwnEA@mail.gmail.com>
 <20120803223634.GO15477@google.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 3 Aug 2012 16:47:47 -0700
Message-ID: <CA+55aFwTa_kYgmFwoWa6hwAAM6=2xTgQQf-vEx_gCzpEMnxodQ@mail.gmail.com>
Subject: Re: [RFC v2 1/7] hashtable: introduce a small and naive hashtable
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org

On Fri, Aug 3, 2012 at 3:36 PM, Tejun Heo <tj@kernel.org> wrote:
>
> I suppose you mean unsized.  I remember this working.  Maybe I'm
> confusing it with zero-sized array.  Hmm... gcc doesn't complain about
> the following.  --std=c99 seems happy too.

Ok, I'm surprised, but maybe it's supposed to work if you do it inside
another struct like that, exactly so that you can preallocate things..

Or maybe it's just a gcc bug. I do think this all is way hackier than
Sasha's original simple code that didn't need these kinds of games,
and didn't need a size member at all.

I really think all the extra complexity and overhead is just *bad*.
The first simple version was much nicer and likely generated better
code too.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
