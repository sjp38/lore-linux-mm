Date: Wed, 13 Sep 2006 13:51:51 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Don't set/test/wait-for radix tree tags if no capability
In-Reply-To: <1158176114.5328.52.camel@localhost>
Message-ID: <Pine.LNX.4.64.0609131350030.19101@schroedinger.engr.sgi.com>
References: <1158176114.5328.52.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 13 Sep 2006, Lee Schermerhorn wrote:

> While debugging a problem [in the out-of-tree migration cache], I
> noticed a lot of radix-tree tag activity for address spaces that have
> the BDI_CAP_NO_{ACCT_DIRTY|WRITEBACK} capability flags set--effectively
> disabling these capabilities--in their backing device.  Altho'
> functionally benign, I believe that this unnecessary overhead.  Seeking
> contrary opinions.

I do not think that not wanting accounting for dirty pages means that we 
should not mark those dirty. If we do this then filesystems will 
not be able to find the dirty pags for writeout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
