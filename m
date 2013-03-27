Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 61C4B6B0039
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 20:43:16 -0400 (EDT)
Received: from localhost (localhost [127.0.0.1])
	by mail.8bytes.org (Postfix) with SMTP id 094DE12AF92
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 01:43:14 +0100 (CET)
Date: Wed, 27 Mar 2013 01:43:14 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH] staging: zsmalloc: Fix link error on ARM
Message-ID: <20130327004314.GH30540@8bytes.org>
References: <1364337232-3513-1-git-send-email-joro@8bytes.org>
 <20130327000552.GA13283@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130327000552.GA13283@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@lge.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Mar 27, 2013 at 09:05:52AM +0900, Minchan Kim wrote:
> And please Cc stable.

Okay, here it is. The result is compile-tested.

Changes since v1:

* Remove the module-export for unmap_kernel_range and make zsmalloc
  built-in instead

Here is the patch:
