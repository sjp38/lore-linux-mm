Date: Thu, 2 Jun 2005 17:53:27 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch] scm: fix scm_fp_list allocation problem
Message-Id: <20050602175327.6e257d94.akpm@osdl.org>
In-Reply-To: <429FA5D4.87FD9B6C@akamai.com>
References: <200506012227.PAA05624@allur.sanmateo.akamai.com>
	<20050602161341.3d94f17b.akpm@osdl.org>
	<429FA5D4.87FD9B6C@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Prasanna Meda <pmeda@akamai.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Prasanna Meda <pmeda@akamai.com> wrote:
>
> >
> > Given that you need to patch the kernel to support larger SCM_MAX_FD, why
> > not add this patch at the same time, keep it out of the main tree?
> 
> Can do.
> Ideally every fd openable should be passed over. I work towards that goal
> and submit again.

No.

I meant that given that you are already patching your personal kernel to make
SCM_MAX_FD larger, why don't you simultaneously apply this patch?

In other words: why does the kernel.org kernel need this patch?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
