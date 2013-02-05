Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id CC7B56B00E1
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 00:20:37 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id fa11so1240435pad.37
        for <linux-mm@kvack.org>; Mon, 04 Feb 2013 21:20:37 -0800 (PST)
Date: Mon, 4 Feb 2013 21:20:34 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: break circular include from linux/mmzone.h
In-Reply-To: <1360037707-13935-1-git-send-email-lig.fnst@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.02.1302042119370.31498@chino.kir.corp.google.com>
References: <1360037707-13935-1-git-send-email-lig.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: liguang <lig.fnst@cn.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On Tue, 5 Feb 2013, liguang wrote:

> linux/mmzone.h included linux/memory_hotplug.h,
> and linux/memory_hotplug.h also included
> linux/mmzone.h, so there's a bad cirlular.
> 

And both of these are protected by _LINUX_MMZONE_H and 
__LINUX_MEMORY_HOTPLUG_H, respectively, so what's the problem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
