Date: Thu, 18 Jul 2002 18:36:13 +0200 (MEST)
From: Szakacsits Szabolcs <szaka@sienet.hu>
Subject: Re: [PATCH] strict VM overcommit for stock 2.4
In-Reply-To: <1027009865.1555.105.camel@sinai>
Message-ID: <Pine.LNX.4.30.0207181806220.30902-100000@divine.city.tvnet.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 18 Jul 2002, Robert Love wrote:

> I do not see anything in this email related to the issue at hand.

You solve a problem and introduce a potentially more serious one.
Strict overcommit is requisite but not satisfactory.

> Specifically, what livelock situation are you insinuating?  If we only
> allow allocation that are met by the backing store, we cannot get
> anywhere near OOM.

This is what I would do first [make sure you don't hit any resource,
malloc, kernel memory mapping, etc limits -- this is a simulation that
must eat all available memory continually]:
main(){void *x;while(1)if(x=malloc(4096))memset(x,666,4096);}

When the above used up all the memory try to ssh/login to the box as
root and clean up the mess. Can you do it?

	Szaka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
