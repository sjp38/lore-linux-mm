Date: Sat, 12 Apr 2003 20:14:40 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.67-mm2
Message-ID: <20030413031440.GA14357@holomorphy.com>
References: <1050198928.597.6.camel@teapot.felipe-alfaro.com> <200304130303.h3D33kkr031006@sith.maoz.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200304130303.h3D33kkr031006@sith.maoz.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Hall <jhall@maoz.com>
Cc: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>, Andrew Morton <akpm@digeo.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 12, 2003 at 11:03:46PM -0400, Jeremy Hall wrote:
> I dunno about that, but mm2 locks in the boot process and doesn't display 
> anything to me through gdb even though it is supposed to.  I have gdb 
> console=gdb but that doesn't make the messages flow.

An early printk patch (any of the several going around) may give you an
idea of where it's barfing.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
