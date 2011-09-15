Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C931A9000BD
	for <linux-mm@kvack.org>; Thu, 15 Sep 2011 18:27:35 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <504b4342-e6b0-4544-b81c-ca41240ac5bf@default>
Date: Thu, 15 Sep 2011 15:27:07 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH v2 0/3] staging: zcache: xcfmalloc support
References: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20110909203447.GB19127@kroah.com> <4E6ACE5B.9040401@vflare.org>
 <4E6E18C6.8080900@linux.vnet.ibm.com> <4E6EB802.4070109@vflare.org>
 <4E6F7DA7.9000706@linux.vnet.ibm.com> <4E6FC8A1.8070902@vflare.org>
 <4E72284B.2040907@linux.vnet.ibm.com>
 <075c4e4c-a22d-47d1-ae98-31839df6e722@default>
 <4E725109.3010609@linux.vnet.ibm.com 1316125062.16137.80.camel@nimitz>
In-Reply-To: <1316125062.16137.80.camel@nimitz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Greg KH <greg@kroah.com>, gregkh@suse.de, devel@driverdev.osuosl.org, cascardo@holoscopio.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brking@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com

> From: Dave Hansen [mailto:dave@linux.vnet.ibm.com]
> Subject: Re: [PATCH v2 0/3] staging: zcache: xcfmalloc support
>=20
> On Thu, 2011-09-15 at 14:24 -0500, Seth Jennings wrote:
> > How would you suggest that I measure xcfmalloc performance on a "very
> > large set of workloads".  I guess another form of that question is: How
> > did xvmalloc do this?
>=20
> Well, it didn't have a competitor, so this probably wasn't done. :)
>=20
> I'd like to see a microbenchmarky sort of thing.  Do a million (or 100
> million, whatever) allocations, and time it for both allocators doing
> the same thing.  You just need to do the *same* allocations for both.

One suggestion:  We already know xvmalloc sucks IF the workload has
poor compression for most pages.  We are looking to understand if xcfmalloc
is [very**N] bad when xvmalloc is good.  So please measure BIG-NUMBER
allocations where compression is known to be OK on average (which is,
I think, a large fraction of workloads), rather than workloads where
xvmalloc already sucks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
