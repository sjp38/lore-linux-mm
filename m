Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id i9QKtiLv240070
	for <linux-mm@kvack.org>; Tue, 26 Oct 2004 16:55:44 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id i9QKtiJm191224
	for <linux-mm@kvack.org>; Tue, 26 Oct 2004 14:55:44 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id i9QKthFa017348
	for <linux-mm@kvack.org>; Tue, 26 Oct 2004 14:55:43 -0600
Subject: Re: [Lhms-devel] Re: 150 nonlinear
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <417EB684.1060100@kolumbus.fi>
References: <E1CJYc0-0000aK-A8@ladymac.shadowen.org>
	 <1098815779.4861.26.camel@localhost>  <417EA06B.5040609@kolumbus.fi>
	 <1098819748.5633.0.camel@localhost>  <417EB684.1060100@kolumbus.fi>
Content-Type: text/plain; charset=ISO-8859-1
Message-Id: <1098824141.6188.1.camel@localhost>
Mime-Version: 1.0
Date: Tue, 26 Oct 2004 13:55:41 -0700
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mika =?ISO-8859-1?Q?Penttil=E4?= <mika.penttila@kolumbus.fi>
Cc: Andy Whitcroft <apw@shadowen.org>, lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2004-10-26 at 13:41, Mika Penttila wrote:
> Ah, you mean Daniel Phillips's initial patch for nonlinear...

No.  Dan had a lovely idea, and a decent implementation, but Dave M
completely reimplemented it as far as I know.  That's why I've been
referring to them as "implementations".

> Ok, so what's the mem_map split? I see Andy renamed it section_mem_map 
> and added NONLINEAR_OPTIMISE, how's that making a difference?

I don't understand the question.  Why do we need to split up mem_map?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
