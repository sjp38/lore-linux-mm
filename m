Received: from westrelay04.boulder.ibm.com (westrelay04.boulder.ibm.com [9.17.193.32])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id i9QJgULv139550
	for <linux-mm@kvack.org>; Tue, 26 Oct 2004 15:42:30 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id i9QJgUd6143770
	for <linux-mm@kvack.org>; Tue, 26 Oct 2004 13:42:30 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id i9QJgTa7008740
	for <linux-mm@kvack.org>; Tue, 26 Oct 2004 13:42:30 -0600
Subject: Re: [Lhms-devel] Re: 150 nonlinear
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <417EA06B.5040609@kolumbus.fi>
References: <E1CJYc0-0000aK-A8@ladymac.shadowen.org>
	 <1098815779.4861.26.camel@localhost>  <417EA06B.5040609@kolumbus.fi>
Content-Type: text/plain; charset=ISO-8859-1
Message-Id: <1098819748.5633.0.camel@localhost>
Mime-Version: 1.0
Date: Tue, 26 Oct 2004 12:42:28 -0700
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mika =?ISO-8859-1?Q?Penttil=E4?= <mika.penttila@kolumbus.fi>
Cc: Andy Whitcroft <apw@shadowen.org>, lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2004-10-26 at 12:07, Mika Penttila wrote:
> What do you consider as Dave M's nonlinear?

This, basically:

http://sprucegoose.sr71.net/patches/2.6.9-rc3-mm3-mhp1/C-nonlinear-base.patch

There's a little there that isn't Dave M's direct work, but it's all in
the spirit of his implementation.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
