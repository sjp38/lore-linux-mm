Date: Wed, 24 Jul 2002 22:30:59 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: page_add/remove_rmap costs
Message-ID: <20020725053059.GF2907@holomorphy.com>
References: <3D3E4A30.8A108B45@zip.com.au> <20020725045040.GD2907@holomorphy.com> <3D3F893D.4074CDE5@zip.com.au> <20020725051552.GA48429@compsoc.man.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <20020725051552.GA48429@compsoc.man.ac.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Levon <levon@movementarian.org>
Cc: Andrew Morton <akpm@zip.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2002 at 06:15:52AM +0100, John Levon wrote:
> Maybe wli used "op_session", and this was from a previous run. oprofile
> < 0.3 had a bug where the vmlinux samples file wasn't moved.

I used an explicit session file argument.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
