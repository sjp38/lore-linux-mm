Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 25D0B6B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 22:28:34 -0400 (EDT)
Date: Fri, 2 Aug 2013 12:28:28 +1000
From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH 2/8] Mark powerpc memory resources as busy
Message-ID: <20130802022827.GB1680@concordia>
References: <51F01E06.6090800@linux.vnet.ibm.com>
 <51F01EB2.9060802@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51F01EB2.9060802@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, isimatu.yasuaki@jp.fujitsu.com

On Wed, Jul 24, 2013 at 01:36:34PM -0500, Nathan Fontenot wrote:
> Memory I/O resources need to be marked as busy or else we cannot remove
> them when doing memory hot remove.

I would have thought it was the opposite?

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
