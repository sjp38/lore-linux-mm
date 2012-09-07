Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 8DCB46B0044
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 18:55:15 -0400 (EDT)
Date: Fri, 7 Sep 2012 15:55:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/7] mm: interval tree updates
Message-Id: <20120907155514.3fad7887.akpm@linux-foundation.org>
In-Reply-To: <CANN689HMxteeUT9q5BgKutEnNQF6sKv2n9ze11Z=wkOoC+XGqw@mail.gmail.com>
References: <1346750457-12385-1-git-send-email-walken@google.com>
	<1346750457-12385-2-git-send-email-walken@google.com>
	<20120907151341.79cb5638.akpm@linux-foundation.org>
	<CANN689HMxteeUT9q5BgKutEnNQF6sKv2n9ze11Z=wkOoC+XGqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, riel@redhat.com, peterz@infradead.org, aarcange@redhat.com, hughd@google.com, daniel.santos@pobox.com, linux-kernel@vger.kernel.org

On Fri, 7 Sep 2012 15:29:36 -0700
Michel Lespinasse <walken@google.com> wrote:

> > Ho hum.  I don't think I can be bothered untangling all this.
> 
> I don't think you should have to do it yourself either.

Patch wrangling is what I do ;)

> But, if you're willing to take it, I can send you replacement patches for
> (mm-replace-vma-prio_tree-with-an-interval-tree.patch +
> mm-interval-tree-updates.patch) collapsed into one, and
> rbtree-move-augmented-rbtree-functionality-to-rbtree_augmentedh.patch
> fixed so that it'd apply after the collapsed patch (and get to the
> same end state).

Yes please, I suppose we should do this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
