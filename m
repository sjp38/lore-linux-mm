Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 7BA796B005A
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 10:21:09 -0400 (EDT)
Message-ID: <1344262863.27828.56.camel@twins>
Subject: Re: [PATCH v2 6/9] rbtree: low level optimizations in rb_erase()
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 06 Aug 2012 16:21:03 +0200
In-Reply-To: <1343946858-8170-7-git-send-email-walken@google.com>
References: <1343946858-8170-1-git-send-email-walken@google.com>
	 <1343946858-8170-7-git-send-email-walken@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: riel@redhat.com, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Thu, 2012-08-02 at 15:34 -0700, Michel Lespinasse wrote:
> +                       /*
> +                        * Case 2: node's successor is its right child



> +                       /* Case 3: node's successor is leftmost under its
> +                        * right child subtree


Hmm?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
