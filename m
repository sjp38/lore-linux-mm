Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 189206B008C
	for <linux-mm@kvack.org>; Mon,  1 Jun 2009 00:45:43 -0400 (EDT)
Date: Sun, 31 May 2009 21:46:23 -0700 (PDT)
Message-Id: <20090531.214623.76344831.davem@davemloft.net>
Subject: Re: [PATCH] Use kzfree in crypto API context initialization and
 key/iv handling
From: David Miller <davem@davemloft.net>
In-Reply-To: <4A22967C.3080304@redhat.com>
References: <20090531025720.GC9033@oblivion.subreption.com>
	<20090530.230213.73434433.davem@davemloft.net>
	<4A22967C.3080304@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: riel@redhat.com
Cc: research@subreption.com, linux-kernel@vger.kernel.org, pageexec@freemail.hu, linux-mm@kvack.org, torvalds@osdl.org, alan@lxorguk.ukuu.org.uk, linux-crypto@vger.kernel.org, herbert@gondor.apana.org.au
List-ID: <linux-mm.kvack.org>

From: Rik van Riel <riel@redhat.com>
Date: Sun, 31 May 2009 10:38:52 -0400

> David Miller wrote:
>> From: "Larry H." <research@subreption.com>
>> Date: Sat, 30 May 2009 19:57:20 -0700
>> 
>>> [PATCH] Use kzfree in crypto API context initialization and key/iv
>>> handling
>> Thanks for not CC:ing the crypto list, and also not CC:'ing the
>> crypto maintainer.
>> Your submissions leave a lot to be desired, on every level.
> 
> That's a pretty roundabout way of saying "I have no
> technical objections" :)

One of those "levels" was technical.

I don't even want to think about what this does to IPSEC rule creation
rates, that that matters heavily for cell phone networks where
hundreds of thousands of nodes come in and out of the server and each
such entry requires creating 4 IPSEC rules.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
