Date: Fri, 11 Jan 2002 23:21:10 +0000
From: Pavel Machek <pavel@suse.cz>
Subject: Re: [PATCH] updated version of radix-tree pagecache
Message-ID: <20020111232110.A260@toy.ucw.cz>
References: <20020105171234.A25383@caldera.de> <3C3972D4.56F4A1E2@loewe-komp.de> <20020107030344.H10391@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20020107030344.H10391@holomorphy.com>; from wli@holomorphy.com on Mon, Jan 07, 2002 at 03:03:44AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Peter W?chtler <pwaechtler@loewe-komp.de>, Christoph Hellwig <hch@caldera.de>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, velco@fadata.bg
List-ID: <linux-mm.kvack.org>

Hi!

> I speculate this would be good for small systems as well as it reduces
> the size of struct page by 2*sizeof(unsigned long) bytes, allowing more
> incremental allocation of pagecache metadata. I haven't tried it on my
> smaller systems yet (due to lack of disk space and needing to build the
> cross-toolchains), though I'm now curious as to its exact behavior there.

Why not mem=8M, nosmp on your "big" system?
								Pavel

-- 
Philips Velo 1: 1"x4"x8", 300gram, 60, 12MB, 40bogomips, linux, mutt,
details at http://atrey.karlin.mff.cuni.cz/~pavel/velo/index.html.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
