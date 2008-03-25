Date: Tue, 25 Mar 2008 10:55:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [11/14] vcompound: Fallbacks for order 1 stack allocations on
 IA64 and x86
In-Reply-To: <20080325075106.GF2170@one.firstfloor.org>
Message-ID: <Pine.LNX.4.64.0803251054320.16374@schroedinger.engr.sgi.com>
References: <20080321061703.921169367@sgi.com> <20080321061726.782068299@sgi.com>
 <871w63iuap.fsf@basil.nowhere.org> <Pine.LNX.4.64.0803241251360.4218@schroedinger.engr.sgi.com>
 <20080325075106.GF2170@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, viro@ftp.linux.org.uk
List-ID: <linux-mm.kvack.org>

On Tue, 25 Mar 2008, Andi Kleen wrote:

> Maybe sparse could be taught to check for this if it happens
> in a single function? (cc'ing Al who might have some thoughts
> on this). Of course if it happens spread out over multiple
> functions sparse wouldn't help neither. 

We could add debugging code to virt_to_page (or __pa) to catch these uses.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
