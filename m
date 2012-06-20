Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id A77DF6B006C
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 22:53:44 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Wed, 20 Jun 2012 08:23:41 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5K2ra1F13828388
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 08:23:37 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5K8NNao001571
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 18:23:24 +1000
Message-ID: <4FE13B2F.4080701@linux.vnet.ibm.com>
Date: Wed, 20 Jun 2012 10:53:35 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 10/10] cleanup the code between tmem_obj_init and tmem_obj_find
References: <4FE0392E.3090300@linux.vnet.ibm.com> <4FE03A55.7070503@linux.vnet.ibm.com> <4FE0AD89.6000001@linux.vnet.ibm.com>
In-Reply-To: <4FE0AD89.6000001@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 06/20/2012 12:49 AM, Seth Jennings wrote:

> This patch causes a crash, details below.


Sorry, i forgot to commit the new changes to my local git tree, and
posted a old patch to the mail list. :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
