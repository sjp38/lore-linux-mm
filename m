Received: by an-out-0708.google.com with SMTP id b38so481707ana
        for <linux-mm@kvack.org>; Thu, 01 Mar 2007 15:44:15 -0800 (PST)
Message-ID: <b00ca3bd0703011544n6a9eccc8gfa9e44964bd68e9d@mail.gmail.com>
Date: Fri, 2 Mar 2007 07:44:15 +0800
From: "Antonino Daplas" <adaplas@gmail.com>
Subject: Re: [Linux-fbdev-devel] [PATCH/RFC 2.6.20 1/2] fbdev, mm: Deferred IO support
In-Reply-To: <20070301140131.GA6603@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070225051312.17454.80741.sendpatchset@localhost>
	 <20070301140131.GA6603@linux-sh.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-fbdev-devel@lists.sourceforge.net, Paul Mundt <lethal@linux-sh.org>, Jaya Kumar <jayakumar.lkml@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 3/1/07, Paul Mundt <lethal@linux-sh.org> wrote:
> On Sun, Feb 25, 2007 at 06:13:12AM +0100, Jaya Kumar wrote:
> > This patch implements deferred IO support in fbdev. Deferred IO is a way to
> > delay and repurpose IO. This implementation is done using mm's page_mkwrite
> > and page_mkclean hooks in order to detect, delay and then rewrite IO. This
> > functionality is used by hecubafb.
> >
> Any updates on this? If there are no other concerns, it would be nice to
> at least get this in to -mm for testing if nothing else.

The driver is already in the -mm tree.

>
> Jaya, can you roll the fsync() patch in to your defio patch? There's not
> much point in keeping them separate.

The fsync() patch was not included by Jaya, I believe.

Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
