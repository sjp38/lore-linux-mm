Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E29E86B03A2
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 14:38:09 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id i5so35173621pfc.15
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 11:38:09 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a8si16574535pfa.200.2017.04.13.11.38.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 11:38:09 -0700 (PDT)
Date: Thu, 13 Apr 2017 20:37:56 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [RFC] Re: Costless huge virtual memory? /dev/same, /dev/null?
Message-ID: <20170413183756.GA17630@kroah.com>
References: <20160229162835.GA2816@var.bordeaux.inria.fr>
 <20170413094200.b4lftvumqt4g36hz@var.youpi.perso.aquilenet.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170413094200.b4lftvumqt4g36hz@var.youpi.perso.aquilenet.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Samuel Thibault <samuel.thibault@ens-lyon.org>, Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Apr 13, 2017 at 11:42:00AM +0200, Samuel Thibault wrote:
> Hello,
> 
> More than one year passed without any activity :)
> 
> I have attached a proposed patch for discussion.

As a rule, I don't apply RFC patches, as obviously the submitter doesn't
think it is worthy of being applied :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
