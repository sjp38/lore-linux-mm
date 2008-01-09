Date: Wed, 9 Jan 2008 12:11:14 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 10/10] x86: Unify percpu.h
In-Reply-To: <1199908430.9834.104.camel@localhost>
Message-ID: <Pine.LNX.4.64.0801091210300.11709@schroedinger.engr.sgi.com>
References: <20080108211023.923047000@sgi.com>  <20080108211025.293924000@sgi.com>
 <1199906905.9834.101.camel@localhost>  <Pine.LNX.4.64.0801091130420.11317@schroedinger.engr.sgi.com>
 <1199908430.9834.104.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: travis@sgi.com, Andrew Morton <akpm@linux-foundation.org>, mingo@elte.hu, Andi Kleen <ak@suse.de>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, tglx@linutronix.de, mingo@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 9 Jan 2008, Dave Hansen wrote:

> Then I really think this particular patch belongs in that other patch
> set.  Here, it makes very little sense, and it's on the end anyway.

It makes sense in that both percpu_32/64 are very small as a result of 
earlier patches and so its justifiable to put them together to simplify 
the next patchset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
