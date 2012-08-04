Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id B81696B005D
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 20:06:10 -0400 (EDT)
Received: by weys10 with SMTP id s10so982415wey.14
        for <linux-mm@kvack.org>; Fri, 03 Aug 2012 17:06:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <501C66C2.2020706@gmail.com>
References: <1344003788-1417-1-git-send-email-levinsasha928@gmail.com>
 <1344003788-1417-2-git-send-email-levinsasha928@gmail.com>
 <20120803171515.GH15477@google.com> <501C407D.9080900@gmail.com>
 <20120803213017.GK15477@google.com> <501C458E.7050000@gmail.com>
 <20120803214806.GM15477@google.com> <501C4E92.1070801@gmail.com>
 <20120803222339.GN15477@google.com> <CA+55aFyOst4c3WHbPVbYkSBdBmLJUui5OvoVOh5AuPMnigwnEA@mail.gmail.com>
 <20120803223634.GO15477@google.com> <CA+55aFwTa_kYgmFwoWa6hwAAM6=2xTgQQf-vEx_gCzpEMnxodQ@mail.gmail.com>
 <501C66C2.2020706@gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 3 Aug 2012 17:05:48 -0700
Message-ID: <CA+55aFziVRRBoTnm2zASGR39W1AB+0=4Sa7qO8e6_hN06ZY8wg@mail.gmail.com>
Subject: Re: [RFC v2 1/7] hashtable: introduce a small and naive hashtable
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org

On Fri, Aug 3, 2012 at 5:03 PM, Sasha Levin <levinsasha928@gmail.com> wrote:
>
> The problem with that code was that it doesn't work with dynamically allocated hashtables, or hashtables that grow/shrink.

Sure. But once you have that kind of complexity, why would you care
about the trivial cases?

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
