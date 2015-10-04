Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id AF7C96B02B7
	for <linux-mm@kvack.org>; Sun,  4 Oct 2015 08:06:43 -0400 (EDT)
Received: by qgt47 with SMTP id 47so128973105qgt.2
        for <linux-mm@kvack.org>; Sun, 04 Oct 2015 05:06:43 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s76si11620887qki.99.2015.10.04.05.06.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Oct 2015 05:06:43 -0700 (PDT)
Date: Sun, 4 Oct 2015 13:06:39 +0100
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 2/2] drivers/base/node.c: skip non-present sections in
 register_mem_sect_under_node
Message-ID: <20151004120639.GA18078@kroah.com>
References: <1a7c81db42986a6fa27260fe189890bffc8a9cce.1440665740.git.jstancek@redhat.com>
 <b12da2996a30cb739146a5eccd068bbe650092a1.1440665740.git.jstancek@redhat.com>
 <20150901071553.GD23114@localhost.localdomain>
 <1670445670.7779783.1441797083045.JavaMail.zimbra@redhat.com>
 <1327703113.14884616.1442910421398.JavaMail.zimbra@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1327703113.14884616.1442910421398.JavaMail.zimbra@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Stancek <jstancek@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Young <dyoung@redhat.com>

On Tue, Sep 22, 2015 at 04:27:01AM -0400, Jan Stancek wrote:
> 
> 
> 
> 
> ----- Original Message -----
> > From: "Jan Stancek" <jstancek@redhat.com>
> > To: gregkh@linuxfoundation.org
> > Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Dave Young" <dyoung@redhat.com>
> > Sent: Wednesday, 9 September, 2015 1:11:23 PM
> > Subject: Re: [PATCH 2/2] drivers/base/node.c: skip non-present sections in register_mem_sect_under_node
> > 
> > Greg,
> > 
> > any thoughts about the patch?
> 
> ping

I need some -mm people to sign off on it, as this code is tricky and I
think has caused problems in the past, and I know nothing about it...

So please resend and get some acks from them and I'll be glad to take
it.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
