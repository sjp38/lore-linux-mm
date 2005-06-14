Subject: Re: [RFC] PageReserved ?
References: <1118783741.4301.357.camel@dyn9047017072.beaverton.ibm.com>
From: Andi Kleen <ak@muc.de>
Date: Tue, 14 Jun 2005 23:47:19 +0200
In-Reply-To: <1118783741.4301.357.camel@dyn9047017072.beaverton.ibm.com> (Badari
 Pulavarty's message of "14 Jun 2005 14:15:42 -0700")
Message-ID: <m1wtowa9w8.fsf@muc.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Badari Pulavarty <pbadari@us.ibm.com> writes:

> Hi,
>
> On Andrew's suggestion, I am looking at possibility of getting
> rid of PageReserved() usage. I see lots of drivers setting this
> flag. I am wondering what was the (intended) purpose of 
> PageReserved() ?

When the page is mapped into user space then the swapper won't 
try to swap it out when that bit is set.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
