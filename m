Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 9720E6B0006
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 02:10:30 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id 10so81150pdi.15
        for <linux-mm@kvack.org>; Tue, 09 Apr 2013 23:10:29 -0700 (PDT)
Date: Tue, 9 Apr 2013 23:10:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 1/3] resource: Add __adjust_resource() for internal
 use
In-Reply-To: <1365440996-30981-2-git-send-email-toshi.kani@hp.com>
Message-ID: <alpine.DEB.2.02.1304092310170.3916@chino.kir.corp.google.com>
References: <1365440996-30981-1-git-send-email-toshi.kani@hp.com> <1365440996-30981-2-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxram@us.ibm.com, guz.fnst@cn.fujitsu.com, tmac@hp.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, jiang.liu@huawei.com

On Mon, 8 Apr 2013, Toshi Kani wrote:

> Added __adjust_resource(), which is called by adjust_resource()
> internally after the resource_lock is held.  There is no interface
> change to adjust_resource().  This change allows other functions
> to call __adjust_resource() internally while the resource_lock is
> held.
> 
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
