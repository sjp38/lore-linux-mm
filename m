Date: Fri, 24 Mar 2000 17:49:18 +0100
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: madvise (MADV_FREE)
Message-ID: <20000324174918.A21581@pcep-jamie.cern.ch>
References: <38DB1772.5665EFA2@intermec.com> <200003241742.MAA02123@ccure.karaya.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <200003241742.MAA02123@ccure.karaya.com>; from Jeff Dike on Fri, Mar 24, 2000 at 12:42:18PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Dike <jdike@karaya.com>
Cc: lars brinkhoff <lars.brinkhoff@intermec.com>, cel@monkey.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jeff Dike wrote:
> Maybe on arches where the hardware provides those bits and the kernel uses 
> them, but the i386 kernel doesn't.

The i386 not-user-mode kernel certainly uses the accessed and dirty bits.
What do you think pte_young does?

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
