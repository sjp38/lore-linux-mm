Received: from westrelay01.boulder.ibm.com (westrelay01.boulder.ibm.com [9.17.195.10])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j35Hx65j727892
	for <linux-mm@kvack.org>; Tue, 5 Apr 2005 13:59:06 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay01.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j35Hx6Oq196526
	for <linux-mm@kvack.org>; Tue, 5 Apr 2005 11:59:06 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j35Hx6xE002581
	for <linux-mm@kvack.org>; Tue, 5 Apr 2005 11:59:06 -0600
Subject: Re: [PATCH 3/6] CKRM: Add limit support for mem controller
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050405174239.GD32645@chandralinux.beaverton.ibm.com>
References: <20050402031346.GD23284@chandralinux.beaverton.ibm.com>
	 <1112623850.24676.8.camel@localhost>
	 <20050405174239.GD32645@chandralinux.beaverton.ibm.com>
Content-Type: text/plain
Date: Tue, 05 Apr 2005 10:59:02 -0700
Message-Id: <1112723942.19430.77.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chandra Seetharaman <sekharan@us.ibm.com>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-04-05 at 10:42 -0700, Chandra Seetharaman wrote:
> On Mon, Apr 04, 2005 at 07:10:50AM -0700, Dave Hansen wrote:
> > "DONTCARE" is also multiplexed.  It means "no guarantee" or "no limit"
> > depending on context.  I don't think it would hurt to have one variable
> > for each of these cases.
> 
> It is agnostic... and the name doesn't suggest one way or other... so, I
> don't see a problem in multiplexing it.

I think that variable names should be as suggestive as possible.  *So*
suggestive that I know what they actually do. :)

> > What does "impl" stand for, anyway?  implied?  implicit? implemented?
> 
> I meant implicit... you can also say implied.... will add in comments to
> the dats structure definition.

How about changing the name of the structure member?  Comments suck.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
