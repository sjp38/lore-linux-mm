Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id CEE9E6B0254
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 10:42:14 -0400 (EDT)
Received: by lbos8 with SMTP id s8so82383023lbo.0
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 07:42:14 -0700 (PDT)
Received: from bes.se.axis.com (bes.se.axis.com. [195.60.68.10])
        by mx.google.com with ESMTP id bc7si1466081lbc.6.2015.10.09.07.42.12
        for <linux-mm@kvack.org>;
        Fri, 09 Oct 2015 07:42:12 -0700 (PDT)
Date: Fri, 9 Oct 2015 16:41:57 +0200
From: Jesper Nilsson <jesper.nilsson@axis.com>
Subject: Re: [PATCH 1/7] cris: Convert cryptocop to use get_user_pages_fast()
Message-ID: <20151009144157.GZ4919@axis.com>
References: <1444123470-4932-1-git-send-email-jack@suse.com>
 <1444123470-4932-2-git-send-email-jack@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1444123470-4932-2-git-send-email-jack@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, linux-cris-kernel <linux-cris-kernel@axis.com>, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jespern@axis.com>

On Tue, Oct 06, 2015 at 11:24:24AM +0200, Jan Kara wrote:
> From: Jan Kara <jack@suse.cz>
> 
> CC: linux-cris-kernel@axis.com
> CC: Mikael Starvik <starvik@axis.com>

Acked-by: Jesper Nilsson <jesper.nilsson@axis.com>

> Signed-off-by: Jan Kara <jack@suse.cz>

/^JN - Jesper Nilsson
-- 
               Jesper Nilsson -- jesper.nilsson@axis.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
