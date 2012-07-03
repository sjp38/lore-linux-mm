Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id C6D9F6B0068
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 20:23:11 -0400 (EDT)
Received: by yenr5 with SMTP id r5so5774276yen.14
        for <linux-mm@kvack.org>; Mon, 02 Jul 2012 17:23:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120630013318.GB27797@google.com>
References: <1340315835-28571-1-git-send-email-riel@surriel.com>
	<1340315835-28571-6-git-send-email-riel@surriel.com>
	<20120630013318.GB27797@google.com>
Date: Mon, 2 Jul 2012 17:23:10 -0700
Message-ID: <CANN689HTeEKGU=tdm-bfsCT5yttL7qGL827zV1XfEe007UE18A@mail.gmail.com>
Subject: Re: [PATCH -mm v2 05/11] mm: get unmapped area from VMA tree
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@surriel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>

On Fri, Jun 29, 2012 at 6:33 PM, Michel Lespinasse <walken@google.com> wrote:
>                 if (!found_here) {      // or if(!addr) or whatever
>                         struct rb_node *rb_prev = NULL;
>                         do {
>                                 if (rb_node != rb_prev &&

Gah, that last line was meant to be if (rb_node->rb_right != rb_prev &&

>                                     node_free_gap(rb_node->rb_right) >= len) {
>                                         rb_node = rb_node->rb_right;
>                                         break;
>                                 }
>                                 rb_prev = rb_node;
>                                 rb_node = rb_parent(rb_node);
>                         } while (rb_node);
>                         continue;
>                 }

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
