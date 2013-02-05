Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 1661B6B0002
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 16:18:03 -0500 (EST)
Date: Tue, 5 Feb 2013 13:18:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: break circular include from linux/mmzone.h
Message-Id: <20130205131801.131dabb1.akpm@linux-foundation.org>
In-Reply-To: <1360043796.4449.24.camel@liguang.fnst.cn.fujitsu.com>
References: <1360037707-13935-1-git-send-email-lig.fnst@cn.fujitsu.com>
	<alpine.DEB.2.02.1302042119370.31498@chino.kir.corp.google.com>
	<1360043796.4449.24.camel@liguang.fnst.cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: li guang <lig.fnst@cn.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 05 Feb 2013 13:56:36 +0800
li guang <lig.fnst@cn.fujitsu.com> wrote:

> ___ 2013-02-04______ 21:20 -0800___David Rientjes_________
> > On Tue, 5 Feb 2013, liguang wrote:
> > 
> > > linux/mmzone.h included linux/memory_hotplug.h,
> > > and linux/memory_hotplug.h also included
> > > linux/mmzone.h, so there's a bad cirlular.
> > > 
> > 
> > And both of these are protected by _LINUX_MMZONE_H and 
> > __LINUX_MEMORY_HOTPLUG_H, respectively, so what's the problem?
> 
> obviously, It's a logical error,
> and It has no more effect other than
> combination of these 2 header files.
> so, why don't we separate them?
> 

Yup, flattening the hierarchy is nice.  And having headers doing mutual
inclusion like this is Just Weird.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
