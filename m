Date: Mon, 25 Feb 2008 18:35:52 +0100
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: Page scan keeps touching kernel text pages
Message-ID: <20080225173551.GA13911@lazybastard.org>
References: <20080224144710.GD31293@lazybastard.org> <20080225150724.GF2604@shadowen.org> <20080225151536.GA13358@lazybastard.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20080225151536.GA13358@lazybastard.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 February 2008 16:15:36 +0100, JA?rn Engel wrote:
> On Mon, 25 February 2008 15:07:24 +0000, Andy Whitcroft wrote:
> 
> > I would expect to find pages below the kernel text as real pages, and
> > potentially on the LRU on some architectures.  Which architecture are
> > you seeing this?  Which zones do the pages belong?
> 
> 32bit x86 (run in qemu, shouldn't make a difference).
> 
> Not sure about the zones.  Let me rerun to check that.

Example output:
scanning zone DMA
page      3fa        3 00000000 628
page      2bf        2 00000000 628
page       97        3 00000000 628
page       98        2 00000000 628
scanning zone DMA
page      2c0        3 00000000 628
page      2c3        2 00000000 628
page       44        3 00000000 628
page       46        2 00000000 628
scanning zone DMA
page       37        3 00000000 628
page       35        2 00000000 628
page       32        3 00000000 628
page       38        2 00000000 628

Looks like all kernel text is in zone DMA.  Second column holds the page
number, third is refcount, fourth is the flags, fifth is the line, which
corresponds to this one after my debugging changes:
		if (!mapping || !remove_mapping(mapping, page))
			goto keep_locked;

JA?rn

-- 
Joern's library part 4:
http://www.paulgraham.com/spam.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
