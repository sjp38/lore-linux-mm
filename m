Date: Mon, 25 Apr 2005 21:00:16 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH]: VM 6/8 page_referenced(): move dirty
Message-Id: <20050425210016.6f8a47d1.akpm@osdl.org>
In-Reply-To: <16994.40677.105697.817303@gargle.gargle.HOWL>
References: <16994.40677.105697.817303@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nikita Danilov <nikita@clusterfs.com> wrote:
>
> transfer dirtiness from pte to the struct page in page_referenced().

This will increase the amount of physical I/O which the machine performs. 

If we're not really confident that we'll soon be able to reclaim a mmapped
page then we shouldn't bother writing it to disk, as it's quite likely that
userspace will redirty the page after we wrote it.

I can envision workloads (such as mmap 80% of memory and continuously dirty
it) which would end up performing continuous I/O with this patch.

IOW: I'm gonna drop this one like it's made of lead!
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
