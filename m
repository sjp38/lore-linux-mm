Received: by qb-out-0506.google.com with SMTP id q17so3711964qba
        for <linux-mm@kvack.org>; Sun, 22 Apr 2007 09:55:22 -0700 (PDT)
Message-ID: <a36005b50704220955u7153ea76sef403442bbc805a5@mail.gmail.com>
Date: Sun, 22 Apr 2007 09:55:18 -0700
From: "Ulrich Drepper" <drepper@gmail.com>
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE
In-Reply-To: <20070422091658.GB1558@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <46247427.6000902@redhat.com>
	 <20070422011810.e76685cc.akpm@linux-foundation.org>
	 <20070422091658.GB1558@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "David S. Miller" <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On 4/22/07, Christoph Hellwig <hch@infradead.org> wrote:
> Why isn't MADV_FREE defined to 5 for linux?  It's our first free madv
> value?  Also the behaviour should better match the one in solaris or BSD,
> the last thing we need is slightly different behaviour from operating
> systems supporting this for ages.

The behavior should indeed be identical.  Both implementations
restrict MADV_FREE to work on anonymous memory and it is unspecified
whether a renewed access yields to a zerod page being created or
whether the old content is still there.  So, just use 0x5 for both the
Linux and Solaris version on sparc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
