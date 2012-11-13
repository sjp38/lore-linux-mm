Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 593786B004D
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 16:07:33 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so5815657pad.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 13:07:32 -0800 (PST)
Date: Tue, 13 Nov 2012 13:07:30 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/1] mm: Export a function to get vm committed memory
In-Reply-To: <1352818957-9229-1-git-send-email-kys@microsoft.com>
Message-ID: <alpine.DEB.2.00.1211131307090.5164@chino.kir.corp.google.com>
References: <1352818957-9229-1-git-send-email-kys@microsoft.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "K. Y. Srinivasan" <kys@microsoft.com>
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com, andi@firstfloor.org, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyuki@gmail.com, mhocko@suse.cz, hannes@cmpxchg.org, yinghan@google.com, dan.magenheimer@oracle.com, konrad.wilk@oracle.com

On Tue, 13 Nov 2012, K. Y. Srinivasan wrote:

> It will be useful to be able to access global memory commitment from device
> drivers. On the Hyper-V platform, the host has a policy engine to balance
> the available physical memory amongst all competing virtual machines
> hosted on a given node. This policy engine is driven by a number of metrics
> including the memory commitment reported by the guests. The balloon driver
> for Linux on Hyper-V will use this function to retrieve guest memory commitment.
> This function is also used in Xen self ballooning code.
> 
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>

Acked-by: David Rientjes <rientjes@google.com>

Very nice!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
