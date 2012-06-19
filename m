Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 0CD306B0068
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 16:09:05 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 19 Jun 2012 16:09:04 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id B423F38C823E
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 16:07:12 -0400 (EDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5JK7BS1158252
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 16:07:11 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5JK6xPA013131
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 14:06:59 -0600
Message-ID: <4FE0DBDD.2090005@linux.vnet.ibm.com>
Date: Tue, 19 Jun 2012 15:06:53 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/10] zcache: fix refcount leak
References: <4FE0392E.3090300@linux.vnet.ibm.com> <4FE03949.4080308@linux.vnet.ibm.com> <4FE08C9A.3010701@linux.vnet.ibm.com> <c10bcaf9-aa56-4d6a-bc2c-310096b4198b@default>
In-Reply-To: <c10bcaf9-aa56-4d6a-bc2c-310096b4198b@default>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Konrad Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>

On 06/19/2012 02:49 PM, Dan Magenheimer wrote:

> My preference would be to fix it the opposite way, by
> checking and ignoring zcache_host in zcache_put_pool.
> The ref-counting is to ensure that a client isn't
> accidentally destroyed while in use (for multiple-client
> users such as ramster and kvm) and since zcache_host is a static
> struct, it should never be deleted so need not be ref-counted.


If we do that, we'll need to comment it.  If we don't, it won't be
obvious why we are refcounting every zcache client except one.  It'll
look like a bug.

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
