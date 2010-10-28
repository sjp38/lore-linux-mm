Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9B1498D0015
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 09:49:09 -0400 (EDT)
Date: Thu, 28 Oct 2010 08:49:05 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: TMPFS Maximum File Size
In-Reply-To: <AANLkTikX2LkCfEAuJAaWJ5FsWC25mkQi2qLCSe=L=4q1@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1010280848130.25874@router.home>
References: <AANLkTikn_44WcCBmWUW=8E3q3=cznZNx=dHdOcgZSKgH@mail.gmail.com> <AANLkTin32b4SaC0PTJpX8Pg4anQ3aSMUZFe0QFbt9y36@mail.gmail.com> <AANLkTim=6Oan-CSnGMD1CTsd5iGRr98X44TAcirQt7Q_@mail.gmail.com> <alpine.DEB.2.00.1010271503360.6255@router.home>
 <AANLkTikX2LkCfEAuJAaWJ5FsWC25mkQi2qLCSe=L=4q1@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Oct 2010, Tharindu Rukshan Bamunuarachchi wrote:

> SLES 11 is running with 2.6.27-45. I think I should turn to IBM/Novell
> for further help.

Good idea.

> I still wonder why this happens only with IBM+SLES 11 kernel ? Same HW
> works with later kernels ?

I have no idea how Novell hacks up their SLES11 kernels. Good to hear that
we do not have the issue upstream.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
