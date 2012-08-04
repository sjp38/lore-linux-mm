Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 053386B005A
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 20:02:49 -0400 (EDT)
Received: by bkcjc3 with SMTP id jc3so606455bkc.14
        for <linux-mm@kvack.org>; Fri, 03 Aug 2012 17:02:48 -0700 (PDT)
Message-ID: <501C66C2.2020706@gmail.com>
Date: Sat, 04 Aug 2012 02:03:14 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC v2 1/7] hashtable: introduce a small and naive hashtable
References: <1344003788-1417-1-git-send-email-levinsasha928@gmail.com> <1344003788-1417-2-git-send-email-levinsasha928@gmail.com> <20120803171515.GH15477@google.com> <501C407D.9080900@gmail.com> <20120803213017.GK15477@google.com> <501C458E.7050000@gmail.com> <20120803214806.GM15477@google.com> <501C4E92.1070801@gmail.com> <20120803222339.GN15477@google.com> <CA+55aFyOst4c3WHbPVbYkSBdBmLJUui5OvoVOh5AuPMnigwnEA@mail.gmail.com> <20120803223634.GO15477@google.com> <CA+55aFwTa_kYgmFwoWa6hwAAM6=2xTgQQf-vEx_gCzpEMnxodQ@mail.gmail.com>
In-Reply-To: <CA+55aFwTa_kYgmFwoWa6hwAAM6=2xTgQQf-vEx_gCzpEMnxodQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org

Hi Linus,

On 08/04/2012 01:47 AM, Linus Torvalds wrote:
> Or maybe it's just a gcc bug. I do think this all is way hackier than
> Sasha's original simple code that didn't need these kinds of games,
> and didn't need a size member at all.
> 
> I really think all the extra complexity and overhead is just *bad*.
> The first simple version was much nicer and likely generated better
> code too.

The problem with that code was that it doesn't work with dynamically allocated hashtables, or hashtables that grow/shrink.

The alternative to going down this path, is going back to the old code and saying that it only works for the simple case, and if you're interested in something more complex it should have it's own different implementation.

Does it make sense? We'll keep the simple & common case simple, and let anyone who needs something more complex than this write it as an extension?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
