Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 528DD6B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 11:51:21 -0400 (EDT)
Message-ID: <1365608342.32127.77.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2 1/3] resource: Add __adjust_resource() for internal
 use
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 10 Apr 2013 09:39:02 -0600
In-Reply-To: <alpine.DEB.2.02.1304092310170.3916@chino.kir.corp.google.com>
References: <1365440996-30981-1-git-send-email-toshi.kani@hp.com>
	 <1365440996-30981-2-git-send-email-toshi.kani@hp.com>
	 <alpine.DEB.2.02.1304092310170.3916@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxram@us.ibm.com, guz.fnst@cn.fujitsu.com, tmac@hp.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, jiang.liu@huawei.com

On Tue, 2013-04-09 at 23:10 -0700, David Rientjes wrote:
> On Mon, 8 Apr 2013, Toshi Kani wrote:
> 
> > Added __adjust_resource(), which is called by adjust_resource()
> > internally after the resource_lock is held.  There is no interface
> > change to adjust_resource().  This change allows other functions
> > to call __adjust_resource() internally while the resource_lock is
> > held.
> > 
> > Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> > Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> 
> Acked-by: David Rientjes <rientjes@google.com>

Great!  Thanks David!
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
