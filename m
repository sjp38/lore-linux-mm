Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id D7B7D6B004F
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 02:51:45 -0400 (EDT)
Date: Tue, 21 Jul 2009 15:50:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Replacing 0x% with %# ?
In-Reply-To: <alpine.DEB.1.00.0907201543230.22052@mail.selltech.ca>
References: <alpine.DEB.1.00.0907201543230.22052@mail.selltech.ca>
Message-Id: <20090721154756.2AB7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Li, Ming Chun" <macli@brc.ubc.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> Hi MM list:
> 
> I am newbie and wish to contribute tiny bit. Before I submit a 
> trivial patch, I would ask if it is worth replacing  '0x%' with '%#' in printk in mm/*.c? 
> If it is going to be noise for you guys, I would drop it and keep silent 
> :).  

Never mind. we already post many trivial cleanup patches.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
