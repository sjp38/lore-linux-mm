Date: Sat, 2 Aug 2003 19:00:55 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.0-test2-mm3
Message-Id: <20030802190055.5e600c20.akpm@osdl.org>
In-Reply-To: <1059875394.618.0.camel@teapot.felipe-alfaro.com>
References: <20030802152202.7d5a6ad1.akpm@osdl.org>
	<1059875394.618.0.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Felipe Alfaro Solana <felipe_alfaro@linuxmail.org> wrote:
>
> On Sun, 2003-08-03 at 00:22, Andrew Morton wrote:
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test2/2.6.0-test2-mm3/
> > 
> > . Con's CPU scheduler rework has been dropped out and Ingo's changes have
> >   been added.
> 
> Why?

Because of the other reasons which I mentioned?  We need additional
infrastructure such as the nanosecond timing to do this right.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
