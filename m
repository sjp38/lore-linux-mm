Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id F37ED6B0007
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 12:30:26 -0500 (EST)
Date: Wed, 30 Jan 2013 12:29:57 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] staging: zsmalloc: remove unused pool name
Message-ID: <20130130172956.GC2217@konrad-lan.dumpdata.com>
References: <1359560212-8818-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <51093F43.2090503@linux.vnet.ibm.com>
 <20130130172159.GA24760@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130130172159.GA24760@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On Wed, Jan 30, 2013 at 06:21:59PM +0100, Greg Kroah-Hartman wrote:
> On Wed, Jan 30, 2013 at 09:41:55AM -0600, Seth Jennings wrote:
> > On 01/30/2013 09:36 AM, Seth Jennings wrote:> zs_create_pool()
> > currently takes a name argument which is
> > > never used in any useful way.
> > >
> > > This patch removes it.
> > >
> > > Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> > 
> > Crud, forgot the Acks...
> > 
> > Acked-by: Nitin Gupta <ngupta@vflare.org>
> > Acked-by: Rik van Riel <riel@redhat.com>
> 
> {sigh} you just made me have to edit your patch by hand, you now owe me
> a beer...
> 
Should we codify that :-)


diff --git a/Documentation/SubmittingPatches b/Documentation/SubmittingPatches
index c379a2a..f879c60 100644
--- a/Documentation/SubmittingPatches
+++ b/Documentation/SubmittingPatches
@@ -94,6 +94,7 @@ includes updates for subsystem X.  Please apply."
 The maintainer will thank you if you write your patch description in a
 form which can be easily pulled into Linux's source code management
 system, git, as a "commit log".  See #15, below.
+If the maintainer has to hand-edit your patch, you owe them a beer.
 
 If your description starts to get long, that's a sign that you probably
 need to split up your patch.  See #3, next.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
