Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id C84AA6B0007
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 10:42:35 -0500 (EST)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 30 Jan 2013 08:42:34 -0700
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 0709519D804C
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 08:42:31 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0UFgSGL132170
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 08:42:28 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0UFfx12010433
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 08:42:00 -0700
Message-ID: <51093F43.2090503@linux.vnet.ibm.com>
Date: Wed, 30 Jan 2013 09:41:55 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] staging: zsmalloc: remove unused pool name
References: <1359560212-8818-1-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1359560212-8818-1-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On 01/30/2013 09:36 AM, Seth Jennings wrote:> zs_create_pool()
currently takes a name argument which is
> never used in any useful way.
>
> This patch removes it.
>
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

Crud, forgot the Acks...

Acked-by: Nitin Gupta <ngupta@vflare.org>
Acked-by: Rik van Riel <riel@redhat.com>

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
