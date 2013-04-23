Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 304DB6B0002
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 10:17:34 -0400 (EDT)
Date: Tue, 23 Apr 2013 10:17:31 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH v3 08/18] gfs2: use ->invalidatepage() length argument
Message-ID: <20130423141731.GG31170@thunk.org>
References: <1365498867-27782-1-git-send-email-lczerner@redhat.com>
 <1365498867-27782-9-git-send-email-lczerner@redhat.com>
 <20130423141631.GF31170@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130423141631.GF31170@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukas Czerner <lczerner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, cluster-devel@redhat.com

On Tue, Apr 23, 2013 at 10:16:31AM -0400, Theodore Ts'o wrote:
> On Tue, Apr 09, 2013 at 11:14:17AM +0200, Lukas Czerner wrote:
> > ->invalidatepage() aop now accepts range to invalidate so we can make
> > use of it in gfs2_invalidatepage().
> > 
> > Signed-off-by: Lukas Czerner <lczerner@redhat.com>
> > Cc: cluster-devel@redhat.com
> 
> To the gfs2 development team, 

Whoops, I missed Steven Whitehouse's Acked-by.  Sorry for the noise,

	  	 	 	    	  - Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
