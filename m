Date: Fri, 16 Apr 2004 23:35:48 +0100
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: msync() behaviour broken for MS_ASYNC, revert patch?
Message-ID: <20040416223548.GA27540@mail.shareable.org>
References: <1080771361.1991.73.camel@sisko.scot.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1080771361.1991.73.camel@sisko.scot.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, linux-kernel <linux-kernel@vger.kernel.org>, Ulrich Drepper <drepper@redhat.com>
List-ID: <linux-mm.kvack.org>

Stephen C. Tweedie wrote:
> I've been looking at a discrepancy between msync() behaviour on 2.4.9
> and newer 2.4 kernels, and it looks like things changed again in
> 2.5.68.

When you say a discrepancy between 2.4.9 and newer 2.4 kernels, do you
mean that the msync() behaviour changed during the 2.4 series?

If so, what was the change?

Thanks,
-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
