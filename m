Date: Fri, 7 Mar 2008 23:31:19 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] [8/13] Enable the mask allocator for x86
In-Reply-To: <86802c440803072235r3ca6013cufae3ed62cd67e60f@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0803072330001.12987@schroedinger.engr.sgi.com>
References: <200803071007.493903088@firstfloor.org>
 <20080307090718.A609E1B419C@basil.firstfloor.org>
 <Pine.LNX.4.64.0803071832500.12220@schroedinger.engr.sgi.com>
 <86802c440803072235r3ca6013cufae3ed62cd67e60f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 7 Mar 2008, Yinghai Lu wrote:

> How about system with only 4G or less?

Then it does not matter unless the devices can only access 1G or 2G.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
