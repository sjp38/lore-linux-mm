Date: Fri, 24 Mar 2000 17:08:28 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: madvise (MADV_FREE)
Message-ID: <20000324170828.C3693@redhat.com>
References: <38DB1772.5665EFA2@intermec.com> <200003241742.MAA02123@ccure.karaya.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <200003241742.MAA02123@ccure.karaya.com>; from jdike@karaya.com on Fri, Mar 24, 2000 at 12:42:18PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Dike <jdike@karaya.com>
Cc: lars brinkhoff <lars.brinkhoff@intermec.com>, lk@tantalophile.demon.co.uk, cel@monkey.org, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, Mar 24, 2000 at 12:42:18PM -0500, Jeff Dike wrote:
> 
> Maybe on arches where the hardware provides those bits and the kernel uses 
> them, but the i386 kernel doesn't.

Sure it does.  It relies utterly on them.  It uses the accessed bit to
perform page aging, and it uses the dirty bit to distinguish between
private and shared pages on writable private vmas, or to mark dirty shared
pages on shared vmas.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
