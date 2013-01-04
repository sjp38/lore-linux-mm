Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 208736B005D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 16:35:25 -0500 (EST)
Date: Fri, 4 Jan 2013 16:35:17 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] mm: export mmu notifier invalidates
Message-ID: <20130104213516.GA7650@infradead.org>
References: <E1Tr9P7-0001AN-S4@eag09.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1Tr9P7-0001AN-S4@eag09.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cliff Wickman <cpw@sgi.com>
Cc: aarcange@redhat.com, akpm@linux-foundation.org, avi@redhat.com, hughd@google.com, mgorman@suse.de, linux-mm@kvack.org

On Fri, Jan 04, 2013 at 09:41:53AM -0600, Cliff Wickman wrote:
> So we request that these two functions be exported.

Can you please post the patch that actually uses it in the same series?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
