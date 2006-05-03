Date: Wed, 03 May 2006 11:06:03 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [PATCH 0/2][RFC] New version of shared page tables
Message-ID: <57DF992082E5BD7D36C9D441@[10.1.1.4]>
In-Reply-To: <Pine.LNX.4.64.0605031650190.3057@blonde.wat.veritas.com>
References: <1146671004.24422.20.camel@wildcat.int.mccr.org>
 <Pine.LNX.4.64.0605031650190.3057@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--On Wednesday, May 03, 2006 16:56:12 +0100 Hugh Dickins <hugh@veritas.com>
wrote:

>> I've done some cleanup and some bugfixing.  Hugh, please review
>> this version instead of the old one.
> 
> Grrr, just as I'm writing up my notes on the last revision!
> I need a new go-faster brain.  Okay, I'll switch over now.

Sorry.

The changes should be relatively minor.  Just a tweak to the unshare
locking and some extra code to handle hugepage copy_page_range, mostly.

Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
