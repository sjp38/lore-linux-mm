Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B8CC36B02A3
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 19:09:47 -0400 (EDT)
Date: Thu, 22 Jul 2010 19:09:35 -0400
From: Ted Ts'o <tytso@mit.edu>
Subject: Re: [patch 6/6] jbd2: remove dependency on __GFP_NOFAIL
Message-ID: <20100722230935.GB16373@thunk.org>
References: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1007201943340.8728@chino.kir.corp.google.com>
 <20100722141437.GA14882@thunk.org>
 <alpine.DEB.2.00.1007221108360.30080@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1007221108360.30080@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andreas Dilger <adilger@sun.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 22, 2010 at 11:09:53AM -0700, David Rientjes wrote:
> 
> I'll change this to
> 
> 	do {
> 		new_transaction = kzalloc(sizeof(*new_transaction),
> 							GFP_NOFS);
> 	} while (!new_transaction);
> 
> in the next phase when I introduce __GFP_KILLABLE (that jbd and jbd2 can't 
> use because they are GFP_NOFS).

OK, I can carry a patch which does this in the ext4 tree to push to
linus when the merge window opens shortly, since the goal is you want
to get rid of __GFP_NOFAIL altogether, right?

      	       	     	    	  	    	   - Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
