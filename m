Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id D0C62440321
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 04:31:43 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so108097537wic.1
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 01:31:43 -0700 (PDT)
Received: from mx3-phx2.redhat.com (mx3-phx2.redhat.com. [209.132.183.24])
        by mx.google.com with ESMTPS id h7si29520920wjz.55.2015.10.05.01.31.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 05 Oct 2015 01:31:42 -0700 (PDT)
Date: Mon, 5 Oct 2015 04:31:36 -0400 (EDT)
From: Jan Stancek <jstancek@redhat.com>
Message-ID: <966246330.24706612.1444033896827.JavaMail.zimbra@redhat.com>
In-Reply-To: <20151004120639.GA18078@kroah.com>
References: <1a7c81db42986a6fa27260fe189890bffc8a9cce.1440665740.git.jstancek@redhat.com> <b12da2996a30cb739146a5eccd068bbe650092a1.1440665740.git.jstancek@redhat.com> <20150901071553.GD23114@localhost.localdomain> <1670445670.7779783.1441797083045.JavaMail.zimbra@redhat.com> <1327703113.14884616.1442910421398.JavaMail.zimbra@redhat.com> <20151004120639.GA18078@kroah.com>
Subject: Re: [PATCH 2/2] drivers/base/node.c: skip non-present sections in
 register_mem_sect_under_node
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Young <dyoung@redhat.com>





----- Original Message -----
> From: "Greg KH" <gregkh@linuxfoundation.org>
> To: "Jan Stancek" <jstancek@redhat.com>
> Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Dave Young" <dyoung@redhat.com>
> Sent: Sunday, 4 October, 2015 2:06:39 PM
> Subject: Re: [PATCH 2/2] drivers/base/node.c: skip non-present sections in register_mem_sect_under_node
> 
> On Tue, Sep 22, 2015 at 04:27:01AM -0400, Jan Stancek wrote:
> > 
> > 
> > 
> > 
> > ----- Original Message -----
> > > From: "Jan Stancek" <jstancek@redhat.com>
> > > To: gregkh@linuxfoundation.org
> > > Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Dave Young"
> > > <dyoung@redhat.com>
> > > Sent: Wednesday, 9 September, 2015 1:11:23 PM
> > > Subject: Re: [PATCH 2/2] drivers/base/node.c: skip non-present sections
> > > in register_mem_sect_under_node
> > > 
> > > Greg,
> > > 
> > > any thoughts about the patch?
> > 
> > ping
> 
> I need some -mm people to sign off on it, as this code is tricky and I
> think has caused problems in the past, and I know nothing about it...

Thanks for response, get_maintainer.pl was giving me only your name.

> 
> So please resend and get some acks from them and I'll be glad to take
> it.

It looks like someone has already beat me to it:

commit 04697858d89e4bf2650364f8d6956e2554e8ef88
  mm: check if section present during memory block registering

Regards,
Jan

> 
> thanks,
> 
> greg k-h
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
