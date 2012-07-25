Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 53E9E6B005D
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 13:55:41 -0400 (EDT)
Message-ID: <501032BF.1010800@redhat.com>
Date: Wed, 25 Jul 2012 13:54:07 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/6] rbtree: faster augmented insert
References: <1342787467-5493-1-git-send-email-walken@google.com> <1342787467-5493-5-git-send-email-walken@google.com>
In-Reply-To: <1342787467-5493-5-git-send-email-walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/20/2012 08:31 AM, Michel Lespinasse wrote:
> Introduce rb_insert_augmented(), which is a version of rb_insert_color()
> with an added callback on tree rotations. This can be used for insertion
> into an augmented tree: the handcoded search phase must be updated to
> maintain the augmented information on insertion, and then the rbtree
> coloring/rebalancing algorithms keep it up to date.
>
> rb_insert_color() is now a special case of rb_insert_augmented() with
> a do-nothing callback. I used inlining to optimize out the callback,
> with the intent that this would generate the same code as previously
> for rb_insert_augmented(). This didn't fully work, as my compiler output
> is now *smaller* than before for that function. Speed wise, they seem
> comparable though.
>
> Signed-off-by: Michel Lespinasse <walken@google.com>

The second version of patch 5/6 takes care of my
concerns about this patch.

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
