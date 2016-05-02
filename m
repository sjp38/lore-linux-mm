Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 92C916B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 03:48:52 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r12so70345556wme.0
        for <linux-mm@kvack.org>; Mon, 02 May 2016 00:48:52 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id n10si14245467wjy.217.2016.05.02.00.48.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 00:48:51 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id w143so15927297wmw.3
        for <linux-mm@kvack.org>; Mon, 02 May 2016 00:48:51 -0700 (PDT)
Date: Mon, 2 May 2016 09:48:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: link references in the merged patch
Message-ID: <20160502074849.GB25265@dhcp22.suse.cz>
References: <20160429081601.GB21977@dhcp22.suse.cz>
 <20160429140628.2f74b36a4bb123a3b81197ea@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160429140628.2f74b36a4bb123a3b81197ea@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

On Fri 29-04-16 14:06:28, Andrew Morton wrote:
> On Fri, 29 Apr 2016 10:16:02 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > Hi Andrew,
> > I was suggesting this during your mm workflow session at LSF/MM so this
> > is just a friendly reminder. Could you add something like tip tree and
> > reference the original email where the patch came from? Tip uses
> > 
> > Link: http://lkml.kernel.org/r/$msg_id
> > 
> > and this is really helpful when trying to find the discussion around the
> > patch. I would even welcome to add such a link for each follow up -fix*
> > patches and do
> > [ $email: $(comment for the follow up chaneg)]
> > Link: http://lkml.kernel.org/r/$msg_id
> > 
> > So it is clear what the follow up change was.
> > 
> 
> Yeah, that's in my todo list (along with "do expense reports", sigh).
> But who ever reads those things?

I do quite often when I try to understand some subtle details which are
not clear from the changelog (that is not an exception) and the
discussion in the email thread sometimes helps. Plus it is good to see
where the fixups came from.

> <fiddle fiddle>
> 
> OK, let's see how this goes.

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
