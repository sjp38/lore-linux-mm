Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C07CA6B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 04:33:42 -0400 (EDT)
Message-ID: <a26097d80818626d3fdb4ba668cc115b.squirrel@www.hardeman.nu>
In-Reply-To: <20090915211408.bb614be5.akpm@linux-foundation.org>
References: <20090915161535.db0a6904.akpm@linux-foundation.org>
    <20090916034650.GD2756@core.coreip.homeip.net>
    <20090915211408.bb614be5.akpm@linux-foundation.org>
Date: Wed, 16 Sep 2009 10:33:39 +0200 (CEST)
Subject: Re: 2.6.32 -mm merge plans
From: David =?iso-8859-1?Q?H=E4rdeman?= <david@hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bjorn Helgaas <bjorn.helgaas@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, September 16, 2009 06:14, Andrew Morton wrote:
> On Tue, 15 Sep 2009 20:46:50 -0700 Dmitry Torokhov
> <dmitry.torokhov@gmail.com> wrote:
>>>
>>> input-add-a-shutdown-method-to-pnp-drivers.patch
>>
>> This should go through PNP tree (do we have one?).
>
> Not really.  Bjorn heeps an eye on pnp.  Sometimes merges through acpi,
> sometimes through -mm.
>
> I'll merge it I guess, but where is the corresponding change to the
> winbond driver?

I posted the most recent version of my patch, which is based on the pnp
layer rather than the acpi layer and which addresses every single comment
I've gotten so far, to linux-input, linux-kernel, Dmitry and you.

It's archived here (among other places):
http://www.spinics.net/lists/linux-input/msg04396.html

I assumed that Dmitry would be the logical person to push the patch
upstream and he indicated some hesitation if the driver would change its
mode of operation completely in a later revision (if the input subsystem
grows IR capabilities that is), see the relevant parts at the end of:

http://www.spinics.net/lists/linux-input/msg04395.html

I don't think these fears are reason enough to block the driver from
inclusion, if the input subsystem grows additional IR capabilities any and
all IR drivers will have to change accordingly and the IR capabilities
will serve to support additional functionality rather than providing a
drastic change to existing functionality.

-- 
David Hardeman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
