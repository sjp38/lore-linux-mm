Date: Tue, 25 Nov 2003 00:54:49 -0500 (EST)
From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Subject: Re: OOps! was: 2.6.0-test9-mm5
In-Reply-To: <20031125054709.GC1331@mis-mike-wstn.matchmail.com>
Message-ID: <Pine.LNX.4.58.0311250053410.4230@montezuma.fsmlabs.com>
References: <20031121121116.61db0160.akpm@osdl.org>
 <20031124225527.GB1343@mis-mike-wstn.matchmail.com>
 <Pine.LNX.4.58.0311241840380.8180@montezuma.fsmlabs.com>
 <20031124235807.GA1586@mis-mike-wstn.matchmail.com>
 <20031125003658.GA1342@mis-mike-wstn.matchmail.com>
 <Pine.LNX.4.58.0311242013270.1859@montezuma.fsmlabs.com>
 <20031125051018.GA1331@mis-mike-wstn.matchmail.com>
 <Pine.LNX.4.58.0311250033170.4230@montezuma.fsmlabs.com>
 <20031125054709.GC1331@mis-mike-wstn.matchmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Fedyk <mfedyk@matchmail.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 24 Nov 2003, Mike Fedyk wrote:

> On Tue, Nov 25, 2003 at 12:33:47AM -0500, Zwane Mwaikambo wrote:
> > Indeed it looks PnPBIOS related, i'll await your other tests.
>
> Ok, I'll get started compiling up some kernels.
>
> Am I right in thinking that the pnpbios patches are in a series, where I
> should revert 4, then 3, etc?

Yes, that should do it. Whenever in doubt you can always refer to;

ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test9/2.6.0-test9-mm5/broken-out/series
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
