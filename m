Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 351346B0062
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 16:50:04 -0400 (EDT)
Received: by ggnf4 with SMTP id f4so876363ggn.14
        for <linux-mm@kvack.org>; Mon, 06 Aug 2012 13:50:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1344262863.27828.56.camel@twins>
References: <1343946858-8170-1-git-send-email-walken@google.com>
	<1343946858-8170-7-git-send-email-walken@google.com>
	<1344262863.27828.56.camel@twins>
Date: Mon, 6 Aug 2012 13:50:02 -0700
Message-ID: <CANN689Gcca_Xr8GQSjJads8psz3PZpya+s8aWTt_goVt0+O4YA@mail.gmail.com>
Subject: Re: [PATCH v2 6/9] rbtree: low level optimizations in rb_erase()
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: riel@redhat.com, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Mon, Aug 6, 2012 at 7:21 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Thu, 2012-08-02 at 15:34 -0700, Michel Lespinasse wrote:
>> +                       /* Case 3: node's successor is leftmost under its
>> +                        * right child subtree
>
> Hmm?

Would 'leftmost under node's right child subtree' make more sense ?

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
