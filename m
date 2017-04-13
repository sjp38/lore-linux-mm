Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 883A06B03B9
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 14:43:03 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z109so7192458wrb.12
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 11:43:03 -0700 (PDT)
Received: from hera.aquilenet.fr (hera.aquilenet.fr. [2a01:474::1])
        by mx.google.com with ESMTP id k79si14358694wmd.51.2017.04.13.11.43.02
        for <linux-mm@kvack.org>;
        Thu, 13 Apr 2017 11:43:02 -0700 (PDT)
Date: Thu, 13 Apr 2017 20:43:00 +0200
From: Samuel Thibault <samuel.thibault@ens-lyon.org>
Subject: Re: [RFC] Re: Costless huge virtual memory? /dev/same, /dev/null?
Message-ID: <20170413184300.gjvbihr36cgadrrv@var.youpi.perso.aquilenet.fr>
References: <20160229162835.GA2816@var.bordeaux.inria.fr>
 <20170413094200.b4lftvumqt4g36hz@var.youpi.perso.aquilenet.fr>
 <20170413183756.GA17630@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170413183756.GA17630@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Greg KH, on jeu. 13 avril 2017 20:37:56 +0200, wrote:
> On Thu, Apr 13, 2017 at 11:42:00AM +0200, Samuel Thibault wrote:
> > More than one year passed without any activity :)
> > 
> > I have attached a proposed patch for discussion.
> 
> As a rule, I don't apply RFC patches, as obviously the submitter doesn't
> think it is worthy of being applied :)

I was indeed not asking for applying it yet, I was guessing it would
raise some discussion, and code often triggers discussion :) But if
there is no objection, I'll indeed propose the patch for inclusion.

Samuel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
