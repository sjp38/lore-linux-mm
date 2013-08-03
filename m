Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 2CDC46B0031
	for <linux-mm@kvack.org>; Sat,  3 Aug 2013 18:10:07 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <51e708ca./Rl3usf4WGIwpz5E%akpm@linux-foundation.org>
References: <51e708ca./Rl3usf4WGIwpz5E%akpm@linux-foundation.org>
Subject: RE: + thp-mm-locking-tail-page-is-a-bug.patch added to -mm tree
Content-Transfer-Encoding: 7bit
Message-Id: <20130803221323.3D69AE0090@blue.fi.intel.com>
Date: Sun,  4 Aug 2013 01:13:23 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, kirill.shutemov@linux.intel.com

akpm@ wrote:
> Subject: + thp-mm-locking-tail-page-is-a-bug.patch added to -mm tree
> To: kirill.shutemov@linux.intel.com,dave.hansen@linux.intel.com
> From: akpm@linux-foundation.org
> Date: Wed, 17 Jul 2013 14:12:42 -0700
> 
> 
> The patch titled
>      Subject: thp, mm: locking tail page is a bug

I forgot about trylock_page().

Andrew, could you fold diff below into the patch.

Thanks.
