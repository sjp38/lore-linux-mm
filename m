Date: Thu, 14 Nov 2002 13:02:20 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [patch] remove hugetlb syscalls
Message-ID: <20021114210220.GM23425@holomorphy.com>
References: <20021113184555.B10889@redhat.com> <20021114203035.GF22031@holomorphy.com> <20021114154809.D20258@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20021114154809.D20258@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 14, 2002 at 12:30:35PM -0800, William Lee Irwin III wrote:
>> The main reason I haven't considered doing this is because they already
>> got in and there appears to be a user (Oracle/IA64).

On Thu, Nov 14, 2002 at 03:48:09PM -0500, Benjamin LaHaise wrote:
> Not in shipping code.  Certainly no vendor kernels that I am aware of 
> have shipped these syscalls yet either, as nearly all of the developers 
> find them revolting.  Not to mention that the code cleanups and bugfixes 
> are still ongoing.

This is a bit out of my hands; the support decision came from elsewhere.
I have to service my users first, and after that, I don't generally want
to stand in the way of others. In general it's good to have minimalistic
interfaces, but I'm not a party to the concerns regarding the syscalls.
My direct involvement there has been either of a kernel janitor nature,
helping to adapt it to Linux kernel idioms, or reusing code for hugetlbfs.

I guess the only real statement left to make is that hugetlbfs (or my
participation/implementation of it) was not originally intended to
compete with the syscalls, though there's a lot of obvious overlap
(which I tried to exploit by means of code reuse).

Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
