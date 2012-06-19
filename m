Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id A46A76B006C
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 12:37:39 -0400 (EDT)
Received: from /spool/local
	by e4.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 19 Jun 2012 12:37:35 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 707C56E8053
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 12:35:21 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5JGZKgh186526
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 12:35:20 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5JGZH7E023330
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 12:35:17 -0400
Message-ID: <4FE0AA3A.8030805@linux.vnet.ibm.com>
Date: Tue, 19 Jun 2012 11:35:06 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/10] zcache: mark zbud_init/zcache_comp_init as __init
References: <4FE0392E.3090300@linux.vnet.ibm.com> <4FE039BE.6010406@linux.vnet.ibm.com>
In-Reply-To: <4FE039BE.6010406@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 06/19/2012 03:35 AM, Xiao Guangrong wrote:

> These functions are called only when system is initializing, so mark __init
> for them to free memory
> 
> Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>


For patches 05-09:

Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
