Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id j0A2wjgg025640
	for <linux-mm@kvack.org>; Sun, 9 Jan 2005 21:58:45 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j0A2wjsq252952
	for <linux-mm@kvack.org>; Sun, 9 Jan 2005 21:58:45 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j0A2wjdX008527
	for <linux-mm@kvack.org>; Sun, 9 Jan 2005 21:58:45 -0500
Subject: Re: page migration patch
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <41DEBB96.3030607@sgi.com>
References: <41D99743.5000601@sgi.com>	<1104781061.25994.19.camel@localhost>
	 <41D9A7DB.2020306@sgi.com> <20050104.234207.74734492.taka@valinux.co.jp>
	 <41DAD2AF.80604@sgi.com> <1104860456.7581.21.camel@localhost>
	 <41DADFB9.2090607@sgi.com>  <41DEBB96.3030607@sgi.com>
Content-Type: text/plain
Date: Sun, 09 Jan 2005 18:58:40 -0800
Message-Id: <1105325920.6788.3.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2005-01-07 at 10:40 -0600, Ray Bryant wrote:
> Attached is a trivial little patch that fixes the names on
> the initial #ifdef and #define in linux/include/mmigrate.h
> to match that file's name (it appears this was copied over from
> some memory hotplug patch and was never updated....)

Looks obvious enough.  Thanks.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
