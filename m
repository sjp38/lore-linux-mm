Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 76B5A6B0002
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 12:18:21 -0500 (EST)
Received: by mail-da0-f42.google.com with SMTP id z17so645679dal.1
        for <linux-mm@kvack.org>; Wed, 13 Feb 2013 09:18:20 -0800 (PST)
Date: Wed, 13 Feb 2013 09:18:17 -0800
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] staging/zcache: Fix/improve zcache writeback code, tie
 to a config option
Message-ID: <20130213171817.GA14694@kroah.com>
References: <1360175261-13287-1-git-send-email-dan.magenheimer@oracle.com>
 <20130206190924.GB32275@kroah.com>
 <761b5c6e-df13-49ff-b322-97a737def114@default>
 <20130206214316.GA21148@kroah.com>
 <abbc2f75-2982-470c-a3ca-675933d112c3@default>
 <20130207000338.GB18984@kroah.com>
 <7393d8c5-fb02-4087-93d1-0f999fb3cafd@default>
 <20130211214944.GA22090@kroah.com>
 <694a9284-7d41-48c6-a55b-634fb2912f43@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <694a9284-7d41-48c6-a55b-634fb2912f43@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: sjenning@linux.vnet.ibm.com, Konrad Wilk <konrad.wilk@oracle.com>, minchan@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@linuxdriverproject.org, ngupta@vflare.org

On Wed, Feb 13, 2013 at 08:55:29AM -0800, Dan Magenheimer wrote:
> For completeness, I thought I should add some planning items
> that ARE new functionality.  In my opinion, these can wait
> until after promotion, but mm developers may have different
> opinions:
> 
> ZCACHE FUTURE NEW FUNCTIONALITY
> 
> A. Support zsmalloc as an alternative high-density allocator
> B. Support zero-filled pages more efficiently
> C. Possibly support three zbuds per pageframe when space allows

Care to send a patch adding all of this "TODO" information to the TODO
file in the kernel so that we don't have to go through all of this again
in 3 months when I forget why I'm now rejecting your patches again?  :)

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
