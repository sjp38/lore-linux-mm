Date: Tue, 18 Mar 2003 16:26:01 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.65-mm1
Message-Id: <20030318162601.78f11739.akpm@digeo.com>
In-Reply-To: <873clkw6ui.fsf@lapper.ihatent.com>
References: <20030318031104.13fb34cc.akpm@digeo.com>
	<87adfs4sqk.fsf@lapper.ihatent.com>
	<87bs08vfkg.fsf@lapper.ihatent.com>
	<20030318160902.C21945@flint.arm.linux.org.uk>
	<873clkw6ui.fsf@lapper.ihatent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Hoogerhuis <alexh@ihatent.com>
Cc: rmk@arm.linux.org.uk, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alexander Hoogerhuis <alexh@ihatent.com> wrote:
>
> I'm not suspecting the PCI in particular for the PCIC-bits, only
> making X and the Radeon work again. But here you are:

Something bad has happened to the Radeon driver in recent kernels.  I've seen
various reports with various syptoms and some suspicion has been directed at
the AGP changes.

But as far as I know nobody has actually got down and done the binary search
to find out exactly when it started happening.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
