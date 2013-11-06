Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id EA6B46B0121
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 17:33:17 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rp8so154174pbb.31
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 14:33:17 -0800 (PST)
Received: from psmtp.com ([74.125.245.197])
        by mx.google.com with SMTP id it5si244172pbc.245.2013.11.06.14.33.15
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 14:33:16 -0800 (PST)
Date: Wed, 6 Nov 2013 14:33:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 2/2] mm: allow to set overcommit ratio more precisely
Message-Id: <20131106143313.1a368250df917fba0faf56fe@linux-foundation.org>
In-Reply-To: <1450211196.19341043.1383727340985.JavaMail.root@redhat.com>
References: <1382101019-23563-1-git-send-email-jmarchan@redhat.com>
	<1382101019-23563-2-git-send-email-jmarchan@redhat.com>
	<20131105155319.732dcbefb162c2ee4716ef9d@linux-foundation.org>
	<1450211196.19341043.1383727340985.JavaMail.root@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave hansen <dave.hansen@intel.com>

On Wed, 6 Nov 2013 03:42:20 -0500 (EST) Jerome Marchand <jmarchan@redhat.com> wrote:

> 
> 
> ----- Original Message -----
> > From: "Andrew Morton" <akpm@linux-foundation.org>
> > To: "Jerome Marchand" <jmarchan@redhat.com>
> > Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "dave hansen" <dave.hansen@intel.com>
> > Sent: Wednesday, November 6, 2013 12:53:19 AM
> > Subject: Re: [PATCH v4 2/2] mm: allow to set overcommit ratio more precisely
> > 
> > On Fri, 18 Oct 2013 14:56:59 +0200 Jerome Marchand <jmarchan@redhat.com>
> > wrote:
> > 
> > > Some applications that run on HPC clusters are designed around the
> > > availability of RAM and the overcommit ratio is fine tuned to get the
> > > maximum usage of memory without swapping. With growing memory, the 1%
> > > of all RAM grain provided by overcommit_ratio has become too coarse
> > > for these workload (on a 2TB machine it represents no less than
> > > 20GB).
> > > 
> > > This patch adds the new overcommit_ratio_ppm sysctl variable that
> > > allow to set overcommit ratio with a part per million precision.
> > > The old overcommit_ratio variable can still be used to set and read
> > > the ratio with a 1% precision. That way, overcommit_ratio interface
> > > isn't broken in any way that I can imagine.
> > 
> > The way we've permanently squished this mistake in the past is to
> > switch to "bytes".  See /proc/sys/vm/*bytes.
> > 
> > Would that approach work in this case?
> > 
> 
> That was my first version of this patch (actually "kbytes" to avoid
> overflow).
> Dave raised the issue that it silently breaks the user interface:
> overcommit_ratio is zero while the system behaves differently.

I don't understand that at all.  We keep overcommit_ratio as-is, with
the same default values and add a different way of altering it.  That
should be back-compatible?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
