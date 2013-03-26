Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id C943B6B0002
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 19:09:12 -0400 (EDT)
Received: by mail-da0-f47.google.com with SMTP id s35so3836914dak.6
        for <linux-mm@kvack.org>; Tue, 26 Mar 2013 16:09:12 -0700 (PDT)
Date: Tue, 26 Mar 2013 16:09:10 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] staging: zsmalloc: Fix link error on ARM
Message-ID: <20130326230910.GA31021@kroah.com>
References: <1364337232-3513-1-git-send-email-joro@8bytes.org>
 <20130326224536.GA29952@kroah.com>
 <20130326230359.GD30540@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130326230359.GD30540@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: devel@driverdev.osuosl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Mar 27, 2013 at 12:03:59AM +0100, Joerg Roedel wrote:
> On Tue, Mar 26, 2013 at 03:45:36PM -0700, Greg Kroah-Hartman wrote:
> > On Tue, Mar 26, 2013 at 11:33:52PM +0100, Joerg Roedel wrote:
> > > Testing the arm chromebook config against the upstream
> > > kernel produces a linker error for the zsmalloc module from
> > > staging. The symbol flush_tlb_kernel_range is not available
> > > there. Fix this by removing the reimplementation of
> > > unmap_kernel_range in the zsmalloc module and using the
> > > function directly.
> > > 
> > > Signed-off-by: Joerg Roedel <joro@8bytes.org>
> > 
> > Why is this not an error for any other architecture?  Why is arm
> > special?
> 
> The version of the function __zs_unmap_object() which uses
> flush_tlb_kernel_range() in the zsmalloc driver is only compiled in when
> USE_PGTABLE_MAPPING is defined. And USE_PGTABLE_MAPPING is defined in
> the same file only when CONFIG_ARM is defined. So this happens only on
> ARM.

Then should I just mark the driver as broken on ARM?

Any reason for not including the driver authors on the Cc: for this
patch?

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
