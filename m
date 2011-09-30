Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7F19000BD
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 14:54:28 -0400 (EDT)
Message-ID: <4E86105B.3070901@zytor.com>
Date: Fri, 30 Sep 2011 11:54:19 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/4] break out unit selection from string_get_size()
References: <20110930180241.D69D5E9C@kernel> <20110930180242.D89C1A59@kernel>
In-Reply-To: <20110930180242.D89C1A59@kernel>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, James.Bottomley@HansenPartnership.com

On 09/30/2011 11:02 AM, Dave Hansen wrote:
> string_get_size() can really only print things in a single
> format.  You're always stuck with a space, and it will
> always zero-pad the decimal places:
> 
> 	4.00 KiB
> 	40.0 KiB
> 	400 KiB
> 
> Printing page sizes in decimal KiB does not make much sense
> since they are always nice powers of two.  But,
> string_get_size() does have some nice code for selecting
> the right units and doing the division.
> 
> This breaks that nice code out so that we can reuse it.
> find_size_units() is a bit of a funky function since it has
> so many outputs.  I don't think it's _too_ crazy though.
> 
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>

For powers of two, wouldn't it make a lot more sense to just do ilog2()
to get the power of two and then the moral equivalent of:

	sprintf("%u %s", 1 << (pw2 % 10), units_str[pw2 / 10]);

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
