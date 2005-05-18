Subject: Re: [PATCH] prevent NULL mmap in topdown model
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <Pine.LNX.4.61.0505181556190.3645@chimarrao.boston.redhat.com>
References: <Pine.LNX.4.61.0505181556190.3645@chimarrao.boston.redhat.com>
Content-Type: text/plain
Date: Wed, 18 May 2005 22:38:02 +0200
Message-Id: <1116448683.6572.43.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2005-05-18 at 15:57 -0400, Rik van Riel wrote:
> This (trivial) patch prevents the topdown allocator from allocating
> mmap areas all the way down to address zero.  It's not the prettiest
> patch, so suggestions for improvement are welcome ;)


it looks like you stop at brk() time.. isn't it better to just stop just
above NULL instead?? Gives you more space and is less of an artificial
barrier..


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
