Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 9B3AE6B0044
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 18:36:39 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2285327pbb.14
        for <linux-mm@kvack.org>; Fri, 03 Aug 2012 15:36:38 -0700 (PDT)
Date: Fri, 3 Aug 2012 15:36:34 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 1/7] hashtable: introduce a small and naive hashtable
Message-ID: <20120803223634.GO15477@google.com>
References: <1344003788-1417-1-git-send-email-levinsasha928@gmail.com>
 <1344003788-1417-2-git-send-email-levinsasha928@gmail.com>
 <20120803171515.GH15477@google.com>
 <501C407D.9080900@gmail.com>
 <20120803213017.GK15477@google.com>
 <501C458E.7050000@gmail.com>
 <20120803214806.GM15477@google.com>
 <501C4E92.1070801@gmail.com>
 <20120803222339.GN15477@google.com>
 <CA+55aFyOst4c3WHbPVbYkSBdBmLJUui5OvoVOh5AuPMnigwnEA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyOst4c3WHbPVbYkSBdBmLJUui5OvoVOh5AuPMnigwnEA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org

On Fri, Aug 03, 2012 at 03:29:10PM -0700, Linus Torvalds wrote:
> On Fri, Aug 3, 2012 at 3:23 PM, Tejun Heo <tj@kernel.org> wrote:
> >
> > I actually meant an enclosing struct.  When you're defining a struct
> > member, simply putting the storage after a struct with var array
> > should be good enough.  If that doesn't work, quite a few things in
> > the kernel will break.
> 
> The unsigned member of a struct has to be the last one, so your struct
> won't work.

I suppose you mean unsized.  I remember this working.  Maybe I'm
confusing it with zero-sized array.  Hmm... gcc doesn't complain about
the following.  --std=c99 seems happy too.

  #include <stdio.h>

  struct A {
	  int i;
	  long ar[];
  };

  struct B {
	  struct A a;
	  long ar_storage[32];
  };

  int main(void)
  {
	  printf("sizeof(A)=%zd sizeof(B)=%zd\n", sizeof(struct A), sizeof(struct B));
	  return 0;
  }

$ ./a.out
sizeof(A)=8 sizeof(B)=264

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
