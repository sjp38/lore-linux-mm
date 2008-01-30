Date: Wed, 30 Jan 2008 15:35:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] SLUB: Fix sysfs refcounting
Message-Id: <20080130153536.0504afe2.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0801291940310.22715@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0801291940310.22715@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jan 2008 19:46:35 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> This patch is needed for correct sysfs operation in slub.
> 
> 
> >From 515049485d863d56f2d54a5a427a4b246fff8d61 Mon Sep 17 00:00:00 2001
> From: Christoph Lameter <clameter@sgi.com>
> Date: Mon, 7 Jan 2008 22:29:05 -0800
> Subject: [PATCH] SLUB: Fix sysfs refcounting
> 
> If CONFIG_SYSFS is set then free the kmem_cache structure when
> sysfs tells us its okay.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

Sorry, but the changelogging here is inadequate.  What is incorrect about
the current behaviour and how does this patch improve things?  What are the
consequences of not merging this patch?  Leak?  Crash?

One of the reasons why this information is important is so I can make a
do-we-need-this-in-stable decision.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
