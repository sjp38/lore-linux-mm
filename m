Date: Thu, 23 Nov 2000 01:42:07 +0000
From: Pavel Machek <pavel@suse.cz>
Subject: Re: [PATCH] Reserved root VM + OOM killer
Message-ID: <20001123014206.D96@toy>
References: <Pine.LNX.4.30.0011221736000.14122-100000@fs129-190.f-secure.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.30.0011221736000.14122-100000@fs129-190.f-secure.com>; from szaka@f-secure.com on Wed, Nov 22, 2000 at 08:09:44PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szabolcs Szakacsits <szaka@f-secure.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

> HOW?
> No performance loss, RAM is always fully utilized (except if no swap),

Handheld machines never have any swap, and alwys have little RAM [trust me,
velo1 I'm writing this on is so tuned that 100KB les and machine is useless].
 Unless reservation  can be turned off, it is not acceptable. Okay, it can
be tuned. Ok, then.

[What about making default reserved space 10% of *swap* size?]

-- 
Philips Velo 1: 1"x4"x8", 300gram, 60, 12MB, 40bogomips, linux, mutt,
details at http://atrey.karlin.mff.cuni.cz/~pavel/velo/index.html.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
