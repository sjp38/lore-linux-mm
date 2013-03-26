Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 597C46B0027
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 19:24:53 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id ro8so5017103pbb.4
        for <linux-mm@kvack.org>; Tue, 26 Mar 2013 16:24:52 -0700 (PDT)
Date: Tue, 26 Mar 2013 16:24:50 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] staging: zsmalloc: Fix link error on ARM
Message-ID: <20130326232450.GA30799@kroah.com>
References: <1364337232-3513-1-git-send-email-joro@8bytes.org>
 <20130326224536.GA29952@kroah.com>
 <20130326230359.GD30540@8bytes.org>
 <20130326230910.GA31021@kroah.com>
 <20130326231941.GE30540@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130326231941.GE30540@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: devel@driverdev.osuosl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Mar 27, 2013 at 12:19:41AM +0100, Joerg Roedel wrote:
> On Tue, Mar 26, 2013 at 04:09:10PM -0700, Greg Kroah-Hartman wrote:
> > On Wed, Mar 27, 2013 at 12:03:59AM +0100, Joerg Roedel wrote:
> 
> > Then should I just mark the driver as broken on ARM?
> 
> Well, at least ARM on SMP, for !SMP the missing function is defined and
> will be inlined.

Then some Kconfig dependancies could be tweaked to try to make this work
properly, not building the driver where it will be broken.

> > Any reason for not including the driver authors on the Cc: for this
> > patch?
> 
> I wasn't sure who the driver author is in the long list of persons from
> the get_maintainer script. So it was more or less lazyness :)
> 
> Should I try to get that patch through the driver authors instead of
> you?

At least cc: them to have them weigh in on the issue, I know they are
trying to do something in this area, but I didn't think it was the same
as your patch.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
