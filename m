Message-ID: <20000404134315.39096@colin.muc.de>
From: Andi Kleen <ak@muc.de>
Subject: Re: Is Linux kernel 2.2.x Pageable?
References: <CA2568B7.003DB4CC.00@d73mta05.au.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA2568B7.003DB4CC.00@d73mta05.au.ibm.com>; from pnilesh@in.ibm.com on Tue, Apr 04, 2000 at 01:15:59PM +0200
Date: Tue, 4 Apr 2000 13:43:16 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pnilesh@in.ibm.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 04, 2000 at 01:15:59PM +0200, pnilesh@in.ibm.com wrote:
> Is Linux kernel 2.2.x pageable ?

No. 

> 
> Is Linux kernel 2.3.x pageable ?

No.

Some parts are voluntarily swappable though (module expire with kmod) 

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
