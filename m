Date: Wed, 30 Jan 2008 16:13:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/6] mm: bdi: tweak task dirty penalty
Message-Id: <20080130161352.4dae48e3.akpm@linux-foundation.org>
In-Reply-To: <20080129154947.110268504@szeredi.hu>
References: <20080129154900.145303789@szeredi.hu>
	<20080129154947.110268504@szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jan 2008 16:49:01 +0100
Miklos Szeredi <miklos@szeredi.hu> wrote:

> Penalizing heavy dirtiers with 1/8-th the total dirty limit might be rather
> excessive on large memory machines. Use sqrt to scale it sub-linearly.

Then again, it might not be.

I'll skip this one.  Please resend if/when it is proven to be a net benefit
across a broad range of workloads.  And stuff like that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
