Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8CJ8mKT011315
	for <linux-mm@kvack.org>; Mon, 12 Sep 2005 15:08:48 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8CJ8lpK097920
	for <linux-mm@kvack.org>; Mon, 12 Sep 2005 15:08:47 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j8CJ8l5F012200
	for <linux-mm@kvack.org>; Mon, 12 Sep 2005 15:08:47 -0400
Subject: Re: [RFC][PATCH 1/2] i386: consolidate discontig functions into
	normal ones
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <4325D150.6040505@kolumbus.fi>
References: <20050912175319.7C51CF96@kernel.beaverton.ibm.com>
	 <4325D150.6040505@kolumbus.fi>
Content-Type: text/plain; charset=ISO-8859-1
Date: Mon, 12 Sep 2005 12:08:41 -0700
Message-Id: <1126552121.5892.28.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mika =?ISO-8859-1?Q?Penttil=E4?= <mika.penttila@kolumbus.fi>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2005-09-12 at 22:04 +0300, Mika Penttila wrote:
> I think you allocate remap pages for nothing in the flatmem case for 
> node0...those aren't used for the mem map in !NUMA.

I believe that is fixed up in the second patch.  It should compile a
do{}while(0) version instead of doing a real call.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
