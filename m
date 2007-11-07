From: Andi Kleen <ak@suse.de>
Subject: Re: [patch 2/2] x86_64: Configure stack size
Date: Thu, 8 Nov 2007 00:12:06 +0100
References: <20071107004357.233417373@sgi.com> <20071107004710.862876902@sgi.com> <20071107191453.GC5080@shadowen.org>
In-Reply-To: <20071107191453.GC5080@shadowen.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200711080012.06752.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: clameter@sgi.com, akpm@linux-foundation.org, linux-mm@kvack.org, travis@sgi.com
List-ID: <linux-mm.kvack.org>

> We seem to be growing two different mechanisms here for 32bit and 64bit.
> This does seem a better option than that in 32bit CONFIG_4KSTACKS etc.
> IMO when these two merge we should consolidate on this version.

Best would be to not change it at all for 64bit for now.

We can worry about the 16k CPU systems when they appear, but shorter term
it would just lead to other crappy kernel code relying on large stacks when
it shouldn't.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
