From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14338.6581.988257.647691@dukat.scot.redhat.com>
Date: Mon, 11 Oct 1999 18:09:09 +0100 (BST)
Subject: Re: MMIO regions
In-Reply-To: <Pine.LNX.4.10.9910061600520.29637-100000@imperial.edgeglobal.com>
References: <14328.64984.364562.947945@dukat.scot.redhat.com>
	<Pine.LNX.4.10.9910061600520.29637-100000@imperial.edgeglobal.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: Linux MM <linux-mm@kvack.org>, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 6 Oct 1999 16:15:59 -0400 (EDT), James Simmons
<jsimmons@edgeglobal.com> said:

>> Look at http://www.precisioninsight.com/dr/locking.html for a
>> description of the cooperative lightweight locking used in the DRI 

> I have read those papers. Its not compatible with fbcon. It would
> require a massive rewrite which would break everything that works with
> fbcon. 

Sure.  It requires that people cooperate in order to take advantage of
the locking protection.

> When people start writing apps using DRI and it locks their machine or
> damages the hardware. Well the linux kernel mailing list will have to
> hear those complaints. You know people will want to write their own
> stuff. Of course precisioninsight should make a licence stating it
> illegal to write your own code using their driver or a warning so they
> don't get their asses sued. These are the kinds of people who will
> look for other solutions like I am. So expect more like me.

You seem to be looking for a solution which doesn't exist, though. :)

It is an unfortunate, but true, fact that the broken video hardware
doesn't let you provide memory mapped access which is (a) fast, (b)
totally safe, and (c) functional.  Choose which of a, b and c you are
willing to sacrifice and then we can look for solutions.  DRI sacrifices
(b), for example, by making the locking cooperative rather than
compulsory.  The basic unaccelerated fbcon sacrifices (c).  Using VM
protection would sacrifice (a).  It's not the ideal choice, sadly.

--Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
