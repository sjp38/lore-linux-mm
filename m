Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j3CGkls0025714
	for <linux-mm@kvack.org>; Tue, 12 Apr 2005 12:46:47 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j3CGkhbs098576
	for <linux-mm@kvack.org>; Tue, 12 Apr 2005 12:46:47 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j3CGkhWw018771
	for <linux-mm@kvack.org>; Tue, 12 Apr 2005 12:46:43 -0400
Subject: Re: question on page-migration code
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050412.084143.41655902.taka@valinux.co.jp>
References: <4255B13E.8080809@engr.sgi.com>
	 <20050407180858.GB19449@logos.cnet> <425AC268.4090704@engr.sgi.com>
	 <20050412.084143.41655902.taka@valinux.co.jp>
Content-Type: text/plain
Date: Tue, 12 Apr 2005 09:46:32 -0700
Message-Id: <1113324392.8343.53.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: raybry@engr.sgi.com, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-04-12 at 08:41 +0900, Hirokazu Takahashi wrote:
> If the method isn't implemented for the page, the migration code
> calls pageout() and try_to_release_page() to release page->private
> instead. 
> 
> Which filesystem are you using? I guess it might be XFS which
> doesn't have the method yet.

Can we more easily detect and work around this in the code, so that this
won't happen for more filesystems?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
