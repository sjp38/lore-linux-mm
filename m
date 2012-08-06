Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 79D426B004D
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 16:46:14 -0400 (EDT)
Received: by yhr47 with SMTP id 47so3585522yhr.14
        for <linux-mm@kvack.org>; Mon, 06 Aug 2012 13:46:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1344263015.27828.58.camel@twins>
References: <1343946858-8170-1-git-send-email-walken@google.com>
	<1343946858-8170-3-git-send-email-walken@google.com>
	<1344263015.27828.58.camel@twins>
Date: Mon, 6 Aug 2012 13:46:12 -0700
Message-ID: <CANN689EHcas5zFyNeDzpapO_ddQiMjbfSwPvjcYQM8ce-Z_zVQ@mail.gmail.com>
Subject: Re: [PATCH v2 2/9] rbtree: optimize fetching of sibling node
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: riel@redhat.com, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Mon, Aug 6, 2012 at 7:23 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Thu, 2012-08-02 at 15:34 -0700, Michel Lespinasse wrote:
>
>> +             tmp = gparent->rb_right;
>> +             if (parent != tmp) {    /* parent == gparent->rb_left */
>
>> +                     tmp = parent->rb_right;
>> +                     if (node == tmp) {
>
>> +                     tmp = parent->rb_left;
>> +                     if (node == tmp) {
>
>> +             sibling = parent->rb_right;
>> +             if (node != sibling) {  /* node == parent->rb_left */
>
> Half of them got a comment, the other half didn't.. is there any
> particular reason for that?

I felt that the equality tests didn't need explanation. But the tests
where I test for inequality with the supposed sibling didn't seem
quite so obvious to me, so I commented them.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
