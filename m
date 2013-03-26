Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 4CD026B0002
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 19:19:43 -0400 (EDT)
Received: from localhost (localhost [127.0.0.1])
	by mail.8bytes.org (Postfix) with SMTP id CE94512AFA1
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 00:19:41 +0100 (CET)
Date: Wed, 27 Mar 2013 00:19:41 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH] staging: zsmalloc: Fix link error on ARM
Message-ID: <20130326231941.GE30540@8bytes.org>
References: <1364337232-3513-1-git-send-email-joro@8bytes.org>
 <20130326224536.GA29952@kroah.com>
 <20130326230359.GD30540@8bytes.org>
 <20130326230910.GA31021@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130326230910.GA31021@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: devel@driverdev.osuosl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 26, 2013 at 04:09:10PM -0700, Greg Kroah-Hartman wrote:
> On Wed, Mar 27, 2013 at 12:03:59AM +0100, Joerg Roedel wrote:

> Then should I just mark the driver as broken on ARM?

Well, at least ARM on SMP, for !SMP the missing function is defined and
will be inlined.

> Any reason for not including the driver authors on the Cc: for this
> patch?

I wasn't sure who the driver author is in the long list of persons from
the get_maintainer script. So it was more or less lazyness :)

Should I try to get that patch through the driver authors instead of
you?


	Joerg


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
