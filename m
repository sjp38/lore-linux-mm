Subject: Re: 2.5.65-mm2
References: <20030319012115.466970fd.akpm@digeo.com>
From: Alexander Hoogerhuis <alexh@ihatent.com>
Date: 19 Mar 2003 11:16:51 +0100
In-Reply-To: <20030319012115.466970fd.akpm@digeo.com>
Message-ID: <87el53acfg.fsf@lapper.ihatent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@digeo.com> writes:
>
> [SNIP]
>

Yay! Still working Radeon :)

And 4x AGP:

agpgart: Putting AGP V2 device at 00:00.0 into 4x mode
agpgart: Putting AGP V2 device at 01:00.0 into 4x mode

Come to think of it, I'll give it a spin, this might be due to a
working DSDT table that was compiled in with ACPI, whereas I had the
1x problems before I did this.

mvh,
A
-- 
Alexander Hoogerhuis                               | alexh@ihatent.com
CCNP - CCDP - MCNE - CCSE                          | +47 908 21 485
"You have zero privacy anyway. Get over it."  --Scott McNealy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
