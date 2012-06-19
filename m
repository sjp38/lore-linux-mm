Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 1B9F96B0062
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 10:37:41 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 19 Jun 2012 10:37:38 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 02B756E805C
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 10:37:05 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5JEb40b199704
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 10:37:04 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5JK7uF0016743
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 16:07:56 -0400
Message-ID: <4FE08E8B.6060000@linux.vnet.ibm.com>
Date: Tue, 19 Jun 2012 09:36:59 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 04/10] zcache: remove unnecessary check of config option
 dependence
References: <4FE0392E.3090300@linux.vnet.ibm.com> <4FE039A6.4050206@linux.vnet.ibm.com>
In-Reply-To: <4FE039A6.4050206@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 06/19/2012 03:34 AM, Xiao Guangrong wrote:

> zcache is enabled only if one of CONFIG_CLEANCACHE and CONFIG_FRONTSWAP is
> enabled, see the Kconfig:
> 	depends on (CLEANCACHE || FRONTSWAP) && CRYPTO=y && X86
> So, we can remove the check in the source code
> 
> Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>


Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
