Date: Mon, 9 Jul 2007 08:50:44 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 00/10] [RFC] SLUB patches for more functionality,
 performance and maintenance
In-Reply-To: <p73y7hrywel.fsf@bingen.suse.de>
Message-ID: <Pine.LNX.4.64.0707090845520.13792@schroedinger.engr.sgi.com>
References: <20070708034952.022985379@sgi.com> <p73y7hrywel.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@google.com
List-ID: <linux-mm.kvack.org>

On Sun, 8 Jul 2007, Andi Kleen wrote:

> Christoph Lameter <clameter@sgi.com> writes:
> 
> > A cmpxchg is less costly than interrupt enabe/disable
> 
> That sounds wrong.

Martin Bligh was able to significantly increase his LTTng performance 
by using cmpxchg. See his article in the 2007 proceedings of the OLS 
Volume 1, page 39.

His numbers were:

interrupts enable disable : 210.6ns
local cmpxchg             : 9.0ns

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
